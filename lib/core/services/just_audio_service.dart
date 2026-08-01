import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AudioSource { local, online, stream }

class JustAudioService {
  static JustAudioService? _instance;

  factory JustAudioService() {
    _instance ??= JustAudioService._internal();
    return _instance!;
  }

  JustAudioService._internal() {
    _init();
  }

  // Callbacks
  Future<void> Function()? _onComplete;
  Future<void> Function()? _onPodcastComplete;
  Future<void> Function()? _onPodcastError;
  Future<void> Function()? _onStreamComplete;
  Future<void> Function()? _onLoading;
  Future<void> Function()? _onReady;

  final StreamProxy _streamProxy = StreamProxy();
  final PodcastProxy _podcastProxy = PodcastProxy();

  final AudioPlayer _player = AudioPlayer(
    useLazyPreparation: true,
    audioLoadConfiguration: AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: const Duration(seconds: 30),
        maxBufferDuration: const Duration(seconds: 60),
        bufferForPlaybackDuration: const Duration(seconds: 3),
        bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 5),
        backBufferDuration: const Duration(seconds: 20),
      ),
    ),
  );
  AudioSource? _source;

  // prevent re-entrant error handling loops
  bool _handlingError = false;

  AudioPlayer getPlayer() => _player;

  Stream<Duration> get position => _player.positionStream;

  Stream<Duration?> get duration => _player.durationStream;

  Stream<IcyMetadata?> get icyMetadataStream => _streamProxy.metadataStream;

  final _loadingController = StreamController<bool>.broadcast();

  Stream<bool?> get processState => _loadingController.stream;

  AudioSource? get source => _source;

  bool _loadingSource = false;

  void _init() {
    _player.processingStateStream.listen((state) {
      _loadingController.add(isLoading());
    });
    // listen for errors
    _player.playbackEventStream.listen((event) async {
      final playerError = event.errorMessage;
      if (playerError != null) {
        debugPrint(
          'JustAudioService: playback error -> ${event.errorCode} | ${event.errorMessage}',
        );
        await _handlePlaybackError(playerError);
      }
    });

    // forward processing state callbacks
    _player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        if (_source == AudioSource.local) {
          await _onComplete?.call();
        } else if (_source == AudioSource.online) {
          await _onPodcastComplete?.call();
        } else {
          await _onStreamComplete?.call();
        }
      } else if (state == ProcessingState.loading) {
        await _onLoading?.call();
      } else if (state == ProcessingState.ready) {
        await _onReady?.call();
      }
    });
  }

  Future<bool> setSource(
    String path,
    AudioSource source, {
    String? cachedFilePath,
    void Function()? onSourceSet,
  }) async {
    try {
      if (source != _source) {
        _loadingSource = false;
        _source = source;
        await release();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_loadingSource) return false;
      await _streamProxy.stopProxy();
      await _podcastProxy.stopProxy();
      _loadingSource = true;
      onSourceSet?.call();
      switch (source) {
        case AudioSource.local:
          await _player.setFilePath(path);
          break;

        case AudioSource.online:
          if (cachedFilePath != null) {
            await _player.setFilePath(cachedFilePath);
          } else {
            final proxyUrl = await _podcastProxy.startProxy(path);
            await _player.setUrl(proxyUrl).timeout(const Duration(seconds: 30));
          }
          break;

        case AudioSource.stream:
          final proxyUrl = await _streamProxy.startProxy(path);
          final address = ProgressiveAudioSource(
            Uri.parse(proxyUrl),
            headers: {'Icy-MetaData': '1', 'Connection': 'close'},
          );
          await _player
              .setAudioSource(address)
              .timeout(const Duration(seconds: 30));
          break;
      }

      await _player.setSpeed(1.0);
      _loadingSource = false;
      _loadingController.add(isLoading());
      onSourceSet?.call();
      return true;
    } catch (e) {
      debugPrint('خطا در setSource: $e');
      _loadingSource = false;
      if (source != _source) return false;
      _source = null;
      await release();
      return false;
    }
  }

  Future<void> play() async => await _player.play();

  bool isPlaying() {
    return _player.playing;
  }

  Future<void> togglePlaying() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> release() async {
    try {
      await _player.stop();
      await _player.clearAudioSources();
    } catch (e) {
      return;
    }
  }

  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> setSpeed(double speed) async => await _player.setSpeed(speed);

  double getSpeed() => _player.speed;

  void setOnComplete(Future<void> Function()? onComplete) {
    _onComplete = onComplete;
  }

  void setOnPodcastComplete(Future<void> Function()? onPodcastComplete) {
    _onPodcastComplete = onPodcastComplete;
  }

  void setOnPodcastError(Future<void> Function()? onPodcastError) {
    _onPodcastError = onPodcastError;
  }

  void setOnStreamComplete(Future<void> Function()? onStreamComplete) {
    _onStreamComplete = onStreamComplete;
  }

  void setOnLoading(Future<void> Function()? onLoading) {
    _onLoading = onLoading;
  }

  void setOnReady(Future<void> Function()? onReady) {
    _onReady = onReady;
  }

  bool isLoading() {
    return _player.processingState == ProcessingState.loading ||
        _player.processingState == ProcessingState.buffering ||
        _loadingSource;
  }

  int getCurrentPosition() {
    final Duration currentPosition = _player.position;
    return currentPosition.inMilliseconds;
  }

  Future<int> getDuration() async {
    Duration? duration;
    while (duration == null) {
      duration = _player.duration;
      await Future.delayed(Duration(milliseconds: 10));
    }
    return duration.inMilliseconds;
  }

  Future<void> setRepeatMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  bool hasSource(AudioSource source) {
    if (_source == null || _source != source) return false;
    return true;
  }

  // ========= error handling & advancing logic =========
  Future<void> _handlePlaybackError(String error) async {
    if (_handlingError) {
      debugPrint('Already handling an error, skipping re-entry');
      return;
    }
    debugPrint('🪲Just Audio Error : $error');
    _handlingError = true;
    if (_source == AudioSource.local) {
      await _onComplete?.call();
    } else if (_source == AudioSource.online) {
      await _onPodcastError?.call();
    } else if (_source == AudioSource.stream) {
      await _onStreamComplete?.call();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _handlingError = false;
  }
}

class PodcastProxy {
  HttpServer? _server;
  HttpClient? _client;

  // نگهداری آخرین درخواست فعال برای مدیریت لغو در صورت سیک (Seek) ناگهانی
  HttpClientRequest? _activeRequest;
  bool _isStopping = false;

  Future<String> startProxy(String targetUrl) async {
    await stopProxy();

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 25)
      ..idleTimeout =
          const Duration(
            minutes: 10,
          ) // افزایش تایم‌آوت برای باز ماندن کانکشن‌ها
      ..maxConnectionsPerHost = 5;

    _server!.listen((HttpRequest request) async {
      if (_isStopping) {
        _respondWithError(request, HttpStatus.serviceUnavailable);
        return;
      }

      // لغو کانکشن قبلی *فقط* در صورتی که پلیر یک درخواست کاملاً جدید (سیک به جای دیگر) بدهد
      _cancelActiveRequest();

      try {
        final uri = Uri.parse(targetUrl);
        _activeRequest = await _client!.getUrl(uri);

        // انتقال دقیق هدر Range پلیر به سرور اصلی برای پشتیبانی از Seek
        final rangeHeader = request.headers.value('range');
        if (rangeHeader != null) {
          _activeRequest!.headers.set('Range', rangeHeader);
        }

        // تنظیم هدرهای استاندارد استریم زنده (اصلاح به keep-alive)
        _activeRequest!.headers
          ..set('Connection', 'keep-alive')
          ..set('User-Agent', 'SoundCenter/2.0')
          ..set('Accept', '*/*');

        final response = await _activeRequest!.close().timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw TimeoutException('Remote server timeout'),
        );

        // انتقال وضعیت (Status Code) و هدرهای پاسخ سرور به پلیر
        request.response.statusCode = response.statusCode;
        response.headers.forEach((name, values) {
          if (name != 'connection') {
            for (var value in values) {
              request.response.headers.add(name, value);
            }
          }
        });
        request.response.headers.set('Connection', 'keep-alive');

        // 🌟 کلید حل مشکل: استفاده از pipe هوشمند دارت
        // این متد مدیریت Backpressure را به طور خودکار به سیستم‌عامل می‌سپارد.
        // وقتی پلیر دانلود را متوقف کند، دارت به صورت خودکار خواندن از سرور اصلی را متوقف می‌کند؛
        // بدون اینکه کانکشن را ببندد یا نیاز به مدیریت دستی بایت‌ها باشد.
        await request.response.addStream(response);
        await request.response.close();
      } catch (e) {
        debugPrint('⚠️ PodcastProxy Error: $e');
        _respondWithError(request, HttpStatus.badGateway);
      }
    });

    final port = _server!.port;
    debugPrint(
      '🚀 PodcastProxy Running on: http://127.0.0.1:$port/podcast.mp3',
    );
    return 'http://127.0.0.1:$port/podcast.mp3';
  }

  void _respondWithError(HttpRequest request, int statusCode) {
    try {
      request.response.statusCode = statusCode;
      request.response.close();
    } catch (_) {}
  }

  void _cancelActiveRequest() {
    try {
      _activeRequest?.abort();
    } catch (_) {}
    _activeRequest = null;
  }

  Future<void> stopProxy() async {
    _isStopping = true;
    _cancelActiveRequest();
    try {
      _client?.close(force: true);
    } catch (_) {}
    _client = null;
    try {
      await _server?.close(force: true);
    } catch (_) {}
    _server = null;
    _isStopping = false;
  }
}

class StreamProxy {
  HttpServer? _server;
  HttpClient? _client;
  HttpClientRequest? _activeRequest;

  // تغییر نوع استریم به مدل دقیق IcyMetadata?
  final StreamController<IcyMetadata?> _metadataController =
      StreamController<IcyMetadata?>.broadcast();

  Stream<IcyMetadata?> get metadataStream => _metadataController.stream;

  Future<String> startProxy(String targetUrl) async {
    // ۱. ابتدا سرور و پروکسی‌های در حال اجرای قبلی را ریست و متوقف کنید
    await stopProxy();

    // ۲. ایجاد سرور محلی روی یک پورت آزاد و تصادفی در محیط لوکال گوشی
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _client = HttpClient();

    // ۳. گوش دادن به درخواست‌های دریافتی از سمت پکیج just_audio
    _server!.listen((HttpRequest request) async {
      try {
        final uri = Uri.parse(targetUrl);
        _activeRequest = await _client!.getUrl(uri);

        // ارسال هدرهای درخواستی آی‌سی به سرور رادیو آنلاین جهت گرفتن متادیتا
        _activeRequest!.headers.set('Icy-MetaData', '1');
        _activeRequest!.headers.set('Connection', 'close');

        // باز کردن کانکشن شبکه با سرور رادیو
        final response = await _activeRequest!.close();

        // ۴. استخراج و پارس کردن کاملاً ایمن هدرها برای جلوگیری از خطای More than one value
        int metaInt = 0;
        int? bitrate;
        String? genre;
        String? name;
        String? url;
        bool? isPublic;

        try {
          // استفاده از [key]?.first به جای value() تداخل هدرهای چندتایی را ۱۰۰٪ حل می‌کند
          final String? icyMetaIntStr = response.headers['icy-metaint']?.first;
          metaInt = icyMetaIntStr != null
              ? int.tryParse(icyMetaIntStr) ?? 0
              : 0;

          final String? icyBrStr = response.headers['icy-metaint']?.first;
          bitrate = icyBrStr != null ? int.tryParse(icyBrStr) : null;

          genre = response.headers['icy-genre']?.first;
          name = response.headers['icy-name']?.first;
          url = response.headers['icy-url']?.first;

          final String? icyPubStr = response.headers['icy-pub']?.first;
          isPublic = icyPubStr != null
              ? (icyPubStr == '1' || icyPubStr.toLowerCase() == 'true')
              : null;
        } catch (e) {
          debugPrint("خطای غیرمترقبه در پارس هدرهای رادیو (بلعیده شد): $e");
        }

        // تنظیم هدرهای پاسخ برای لوکال هاست جهت تحویل دیتای تمیز به پلیر
        request.response.headers.contentType = response.headers.contentType;
        request.response.statusCode = response.statusCode;
        request.response.headers.set('Cache-Control', 'no-cache');

        int bytesUntilMeta = metaInt;
        List<int> metaBuffer = [];
        int metaLength = 0;
        bool readingMetaLength = false;
        bool readingMetaText = false;

        // ۵. شروع لوپ خواندن بایت‌ها به صورت تکه تکه (Chunked)
        await for (var chunk in response) {
          if (_server == null) {
            break; // اگر پروکسی بسته شد، فوراً از حلقه خارج شو
          }

          if (metaInt == 0) {
            // اگر رادیو ساختار متادیتا درون‌خطی نداشت، دیتا مستقیماً فرستاده می‌شود
            request.response.add(chunk);
            await request.response.flush();
            continue;
          }

          int chunkOffset = 0;
          while (chunkOffset < chunk.length) {
            if (!readingMetaLength && !readingMetaText) {
              // الف) تفکیک بایت‌های موزیک معمولی: فرستادن بایت‌های خالص صوتی به پلیر بدون نویز
              int bytesToRead = chunk.length - chunkOffset;
              if (bytesToRead > bytesUntilMeta) bytesToRead = bytesUntilMeta;

              final audioBytes = chunk.sublist(
                chunkOffset,
                chunkOffset + bytesToRead,
              );
              request.response.add(audioBytes);

              chunkOffset += bytesToRead;
              bytesUntilMeta -= bytesToRead;

              if (bytesUntilMeta == 0) {
                readingMetaLength =
                    true; // رسیدن به فاز بایت تعیین‌کننده طول متادیتا
              }
            } else if (readingMetaLength) {
              // ب) محاسبه اندازه طول متادیتا (بایت دریافتی ضربدر ۱۶ مساوی بایت‌های متن)
              int lengthByte = chunk[chunkOffset];
              chunkOffset++;
              metaLength = lengthByte * 16;
              readingMetaLength = false;

              if (metaLength > 0) {
                readingMetaText = true;
                metaBuffer.clear();
              } else {
                bytesUntilMeta =
                    metaInt; // متادیتا در این بخش خالی بود، بازگشت به فاز صدا
              }
            } else if (readingMetaText) {
              // ج) جمع‌آوری بایت‌های متنی شامل اطلاعات خواننده و آهنگ
              int bytesToRead = chunk.length - chunkOffset;
              if (bytesToRead > metaLength) bytesToRead = metaLength;

              metaBuffer.addAll(
                chunk.sublist(chunkOffset, chunkOffset + bytesToRead),
              );
              chunkOffset += bytesToRead;
              metaLength -= bytesToRead;

              if (metaLength == 0) {
                readingMetaText = false;
                bytesUntilMeta = metaInt;

                // تبدیل بایت‌ها به رشته متنی و استخراج فیلد StreamTitle
                final metaText = String.fromCharCodes(metaBuffer);
                if (metaText.contains("StreamTitle='")) {
                  final rawTitle = metaText
                      .split("StreamTitle='")[1]
                      .split("';")[0];

                  // ساخت شیء هدر رسمی پکیج just_audio با اطلاعات پارس شده
                  IcyHeaders headers = IcyHeaders(
                    bitrate: bitrate,
                    genre: genre,
                    name: name,
                    metadataInterval: metaInt,
                    url: url,
                    isPublic: isPublic,
                  );

                  // شبیه‌سازی و ساخت شیء رسمی نهایی IcyMetadata
                  final simulatedMetadata = IcyMetadata(
                    headers: headers,
                    info: IcyInfo(title: rawTitle, url: targetUrl),
                  );

                  _metadataController.add(simulatedMetadata);
                }
              }
            }
          }
          await request.response.flush();
        }
      } catch (e) {
        debugPrint("Proxy implementation error: $e");
      } finally {
        try {
          await request.response.close();
        } catch (_) {}
      }
    });

    return 'http://localhost:${_server!.port}/stream.mp3';
  }

  Future<void> stopProxy() async {
    try {
      _metadataController.add(null); // ارسال وضعیت تهی به شنونده‌ها هنگام توقف
      _activeRequest?.abort();
      _activeRequest = null;
      _client?.close(force: true);
      _client = null;
      await _server?.close(force: true);
      _server = null;
    } catch (e) {
      debugPrint("Error stopping proxy: $e");
    }
  }
}
