// ignore_for_file: depend_on_referenced_packages

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;
import 'package:sound_center/shared/widgets/loading.dart';

/// ---------------------------------------------------------------
/// 1. ویجت اصلی
/// ---------------------------------------------------------------
class NetworkCacheImage extends StatelessWidget {
  const NetworkCacheImage({
    super.key,
    required this.url,
    this.size = 50,
    this.memCacheSize = 400,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double? size;
  final int memCacheSize;
  final BoxFit fit;

  // -----------------------------------------------------------------
  // CDN‑proxy (weserv.nl) – اگر کار نکرد به URL اصلی برمی‌گردد
  // -----------------------------------------------------------------
  static String _proxyUrl(String originalUrl) {
    return 'https://images.weserv.nl/'
        '?url=${Uri.encodeComponent(originalUrl)}'
        '&w=400&h=400&fit=cover&q=75&output=jpg';
  }

  // -----------------------------------------------------------------
  // CacheManager با سرویس سفارشی (fallback + compress)
  // -----------------------------------------------------------------
  static final customCacheManager = CacheManager(
    Config(
      'soundCenterImageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'imageCacheInfo'),
      fileService: FallbackHttpFileService(width: 400, quality: 75),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _fallback();

    final proxy = _proxyUrl(url!);

    return CachedNetworkImage(
      imageUrl: proxy,
      cacheManager: customCacheManager,
      cacheKey: url!,
      // کش بر اساس URL اصلی (جلوگیری از کش تکراری)
      width: size,
      height: size,
      fit: fit,
      memCacheWidth: memCacheSize,
      memCacheHeight: memCacheSize,
      filterQuality: FilterQuality.high,
      placeholder: (_, _) => const Loading(),
      fadeInDuration: const Duration(milliseconds: 300),
      errorWidget: (context, _, error) {
        // CDN شکست → fallback به URL اصلی
        debugPrint('CDN failed → fallback to original: $error');
        return CachedNetworkImage(
          imageUrl: url!,
          cacheManager: customCacheManager,
          cacheKey: url!,
          width: size,
          height: size,
          fit: fit,
          memCacheWidth: memCacheSize,
          memCacheHeight: memCacheSize,
          placeholder: (_, _) => const Loading(),
          errorWidget: (_, _, _) => _fallback(),
        );
      },
    );
  }

  Widget _fallback() {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.scaleDown,
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

      // حجم دانلود شده (قبل از فشرده‌سازی)
      // debugPrint('Downloaded: ${_fmt(bytes.length)} ← $url');

      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final Uint8List compressed = isProxy ? bytes : _compress(decoded);

        // حجم بعد از فشرده‌سازی + صرفه‌جویی
        // debugPrint(
        //   'Compressed: ${_fmt(compressed.length)} '
        //   '(Saved: ${_fmt(bytes.length - compressed.length)})',
        // );

        return _MemoryResponse(compressed, response.validTill, 'jpg');
      }
    } on Exception catch (e) {
      debugPrint('دانلود ناموفق ($url) → $e');
      if (isProxy) {
        return await get(originalUrl, headers: headers);
      }
      rethrow;
    }

    if (isProxy) {
      return await get(originalUrl, headers: headers);
    }

    return _MemoryResponse(Uint8List(0), DateTime.now(), 'jpg');
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

  // نمایش خوانا حجم (B, KB, MB)
  // String _fmt(int bytes) {
  //   if (bytes < 1024) return '$bytes B';
  //   if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  //   return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  // }
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
