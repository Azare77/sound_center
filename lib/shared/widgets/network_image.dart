// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/database/shared_preferences/app_setting_storage.dart';
import 'package:sound_center/shared/widgets/loading.dart';

/// ---------------------------------------------------------------
/// نکته حریم‌خصوصی (عمداً حذف نشد، فقط مستند شد):
/// هر URL تصویر از طریق images.weserv.nl (یک proxy شخص ثالث) رد می‌شود.
/// یعنی این سرویس متادیتای این‌که کاربر چه کاور/آلبومی را می‌بیند دریافت
/// می‌کند. اگر حریم خصوصی برایتان مهم است، این تصمیم را آگاهانه بگیرید:
/// یا خودتان یک image-resizing proxy روی سرور خودتان بزنید، یا این لایه
/// را کاملاً حذف کنید و فقط از originalUrl استفاده کنید.
/// ---------------------------------------------------------------

/// ---------------------------------------------------------------
/// 1. ویجت اصلی
/// ---------------------------------------------------------------
class NetworkCacheImage extends StatelessWidget {
  const NetworkCacheImage({
    super.key,
    required this.url,
    this.size = 50,
    this.memCacheSize = 400,
    this.quality = 75,
    this.fit = BoxFit.cover,
    this.blur = 0,
  });

  final String? url;
  final double? size;

  /// عرض/ارتفاعی که هم برای resize واقعی روی دیسک (در حالت کیفیت پایین)
  /// و هم برای memCacheWidth/Height استفاده می‌شود. برخلاف نسخه قبلی،
  /// این مقدار واقعاً روی فایل کش‌شده روی دیسک هم اثر می‌گذارد.
  final int memCacheSize;

  /// کیفیت فشرده‌سازی JPEG در حالت کیفیت پایین (۰ تا ۱۰۰).
  final int quality;

  final BoxFit fit;
  final double blur;

  // -----------------------------------------------------------------
  // اصلاح آدرس به کیفیت مشخص‌شده.
  // static شده تا هم از build() و هم از NetworkCacheImage.getFile()
  // (برای جاهایی که بدون خود ویجت، مستقیم فایل کش‌شده لازم دارید)
  // قابل استفاده باشد.
  // -----------------------------------------------------------------
  static String _resolveUrl(
    String originalUrl, {
    required bool forHighQuality,
  }) {
    if (!forHighQuality) return originalUrl;

    const patterns = ['-large.', '-t500x500.', '-t300x300.'];
    for (final pattern in patterns) {
      if (originalUrl.contains(pattern)) {
        return originalUrl.replaceAll(pattern, '-original.');
      }
    }

    // هیچ پترن شناخته‌شده‌ای مچ نشد؛ به‌جای سکوت، این حالت را trace‌پذیر می‌کنیم
    // چون یعنی درخواست HQ عملاً به کیفیت پایین fallback شده.
    assert(() {
      debugPrint(
        'NetworkCacheImage: no HQ pattern matched for "$originalUrl", '
        'falling back to original URL as-is.',
      );
      return true;
    }());
    return originalUrl;
  }

  // -----------------------------------------------------------------
  // CDN‑proxy (weserv.nl)
  // -----------------------------------------------------------------
  static String _proxyUrl(
    String originalUrl, {
    required bool forHighQuality,
    required int width,
    required int quality,
  }) {
    final resolved = _resolveUrl(originalUrl, forHighQuality: forHighQuality);
    if (forHighQuality) {
      return 'https://images.weserv.nl/'
          '?url=${Uri.encodeComponent(resolved)}'
          '&q=100&output=jpg';
    }
    return 'https://images.weserv.nl/'
        '?url=${Uri.encodeComponent(resolved)}'
        '&w=$width&h=$width&fit=cover&q=$quality&output=jpg';
  }

  static String _cacheKey(
    String resolvedUrl, {
    required bool isHighQuality,
    required int width,
  }) => 'hq_${isHighQuality}_w${width}_$resolvedUrl';

  // -----------------------------------------------------------------
  // کش منیجر کیفیت بالا (بدون فشرده‌سازی و بدون تغییر ابعاد) — singleton،
  // چون همیشه با همان پارامترها (بدون resize) کار می‌کند.
  // -----------------------------------------------------------------
  static final CacheManager _highQualityCacheManager = CacheManager(
    Config(
      'soundCenterHQImageCache',
      stalePeriod: const Duration(days: 5),
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: 'hqImageCacheInfo'),
      fileService: HttpFileService(),
    ),
  );

  // -----------------------------------------------------------------
  // کش منیجرهای کیفیت پایین، به ازای هر ترکیب (width, quality) یک نمونه.
  // این‌طوری memCacheSize/quality که به ویجت پاس می‌دهید واقعاً روی فایلی
  // که روی دیسک کش می‌شود هم اثر می‌گذارد (نسخه قبلی این را نادیده می‌گرفت
  // چون یک instance ثابت با width=400 برای همه استفاده می‌شد).
  // -----------------------------------------------------------------
  static final Map<String, CacheManager> _lowQualityManagers = {};

  static CacheManager _lowQualityManagerFor(int width, int quality) {
    final key = '${width}_$quality';
    return _lowQualityManagers.putIfAbsent(key, () {
      return CacheManager(
        Config(
          'soundCenterImageCache_$key',
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 200,
          repo: JsonCacheInfoRepository(databaseName: 'imageCacheInfo_$key'),
          fileService: FallbackHttpFileService(width: width, quality: quality),
        ),
      );
    });
  }

  // -----------------------------------------------------------------
  // دسترسی مستقیم به فایل کش‌شده، بدون رندر ویجت — برای جاهایی که فقط
  // File خام لازم دارید (مثلاً برای اشتراک‌گذاری، ست کردن روی نوتیفیکیشن،
  // یا هر مصرف دیگری بیرون از درخت ویجت).
  //
  // جایگزین صحیح الگوی قبلی:
  //   NetworkCacheImage.customCacheManager.getSingleFile(url)
  // که همیشه کیفیت پایین و بدون proxy برمی‌گرداند و به تنظیمات کاربر
  // (AppSettingStorage.getImageQualityState) هیچ توجهی نمی‌کرد.
  //
  // این متد همان مسیر build() را طی می‌کند: چک تنظیمات کیفیت، ساخت آدرس
  // proxy یا آدرس original بر همان اساس، و گرفتن فایل از cache manager
  // درستِ متناظر با آن کیفیت/سایز.
  // -----------------------------------------------------------------
  static Future<File?> getFile(
    String? url, {
    int width = 400,
    int quality = 75,
  }) async {
    if (url == null || url.isEmpty) {
      return null;
    }

    final bool highQuality = AppSettingStorage.getImageQualityState();
    final resolvedUrl = _resolveUrl(url, forHighQuality: highQuality);
    final proxy = _proxyUrl(
      url,
      forHighQuality: highQuality,
      width: width,
      quality: quality,
    );
    final cacheManager = highQuality
        ? _highQualityCacheManager
        : _lowQualityManagerFor(width, quality);
    final cacheKey = _cacheKey(
      resolvedUrl,
      isHighQuality: highQuality,
      width: width,
    );

    try {
      return await cacheManager.getSingleFile(proxy, key: cacheKey);
    } catch (e) {
      debugPrint('NetworkCacheImage.getFile: proxy failed for $url → $e');
      // همان fallback منطق ویجت: اگر proxy شکست خورد، برو سراغ URL اصلی.
      return cacheManager.getSingleFile(resolvedUrl, key: cacheKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _fallback();

    final bool highQuality = AppSettingStorage.getImageQualityState();
    final int width = memCacheSize;

    final resolvedUrl = _resolveUrl(url!, forHighQuality: highQuality);
    final proxy = _proxyUrl(
      url!,
      forHighQuality: highQuality,
      width: width,
      quality: quality,
    );
    final cacheManager = highQuality
        ? _highQualityCacheManager
        : _lowQualityManagerFor(width, quality);
    final cacheKey = _cacheKey(
      resolvedUrl,
      isHighQuality: highQuality,
      width: width,
    );

    final image = CachedNetworkImage(
      imageUrl: proxy,
      cacheManager: cacheManager,
      cacheKey: cacheKey,
      width: size,
      height: size,
      fit: fit,
      memCacheWidth: highQuality ? null : width,
      memCacheHeight: highQuality ? null : width,
      filterQuality: FilterQuality.high,
      placeholder: (_, __) => const Loading(),
      fadeInDuration: const Duration(milliseconds: 300),
      errorWidget: (context, _, error) {
        debugPrint('CDN proxy failed → falling back to original URL: $error');
        return CachedNetworkImage(
          imageUrl: resolvedUrl,
          cacheManager: cacheManager,
          cacheKey: cacheKey,
          width: size,
          height: size,
          fit: fit,
          memCacheWidth: highQuality ? null : width,
          memCacheHeight: highQuality ? null : width,
          placeholder: (_, __) => const Loading(),
          errorWidget: (_, __, ___) => _fallback(),
        );
      },
    );

    // ImageFiltered فقط وقتی واقعاً بلوری خواسته شده ساخته می‌شود؛
    // در نسخه قبلی همیشه (حتی با blur=0) یک لایه اضافه به compositing
    // tree اضافه می‌شد.
    if (blur <= 0) return image;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: image,
    );
  }

  Widget _fallback() {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/default-cover.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// 2. سرویس HTTP با fallback + compress
/// ---------------------------------------------------------------
class FallbackHttpFileService extends HttpFileService {
  final int width;
  final int quality;

  FallbackHttpFileService({this.width = 400, this.quality = 75});

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final bool isProxy = url.contains('images.weserv.nl');
    final String originalUrl = isProxy
        ? Uri.decodeComponent(url.split('url=')[1].split('&')[0])
        : url;

    try {
      final response = await super.get(url, headers: headers);
      final Uint8List bytes = await _readStream(response.content);

      if (bytes.isEmpty) {
        throw Exception('empty response body for $url');
      }

      // weserv خودش resize/compress را انجام داده؛ decode مجدد فقط برای
      // دور انداختن نتیجه، اتلاف CPU روی پرمصرف‌ترین مسیر کد است.
      // بایت‌ها را همان‌طور که هستند برمی‌گردانیم.
      if (isProxy) {
        return _MemoryResponse(bytes, response.validTill, 'jpg');
      }

      // این‌جا مسیر غیر-proxy است (مثلاً retry با originalUrl)؛ این‌جا
      // واقعاً خودمان باید resize/compress کنیم، پس decode لازم است.
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw Exception('failed to decode image bytes for $url');
      }
      final Uint8List compressed = _compress(decoded);
      return _MemoryResponse(compressed, response.validTill, 'jpg');
    } on Exception catch (e) {
      debugPrint('دانلود ناموفق ($url) → $e');
      if (isProxy) {
        return get(originalUrl, headers: headers);
      }
      rethrow;
    }
  }

  Future<Uint8List> _readStream(Stream<List<int>> stream) async {
    final builder = BytesBuilder();
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  Uint8List _compress(img.Image image) {
    final resized = img.copyResize(image, width: width);
    return img.encodeJpg(resized, quality: quality);
  }
}

/// ---------------------------------------------------------------
/// 3. پاسخ حافظه‌ای (بدون نوشتن روی دیسک)
/// ---------------------------------------------------------------
class _MemoryResponse implements FileServiceResponse {
  final Uint8List _bytes;
  final DateTime _validTill;
  final String _fileExtension;

  _MemoryResponse(this._bytes, this._validTill, this._fileExtension);

  @override
  Stream<List<int>> get content async* {
    if (_bytes.isNotEmpty) yield _bytes;
  }

  @override
  int? get contentLength => _bytes.length;

  @override
  String? get eTag => null;

  @override
  String get fileExtension => _fileExtension;

  @override
  DateTime get validTill => _validTill;

  @override
  int get statusCode => _bytes.isNotEmpty ? 200 : 404;
}
