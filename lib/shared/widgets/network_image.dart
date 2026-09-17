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

/// Privacy note (intentionally not removed, only documented):
/// Every image URL is routed through images.weserv.nl (a third-party proxy).
/// This means the service receives metadata about which cover/album the user
/// is viewing. If privacy is important to you, make this decision consciously:
/// either run your own image-resizing proxy on your own server, or remove this
/// layer entirely and use only the originalUrl.

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

  /// Width/height used both for actual resizing on disk (in low-quality mode)
  /// and for memCacheWidth/Height. Unlike the previous version, this value
  /// actually affects the cached file on disk as well.
  final int memCacheSize;

  /// JPEG compression quality in low-quality mode (0 to 100).
  final int quality;

  final BoxFit fit;
  final double blur;

  // Resolve the URL to the specified quality.
  // Made static so it can be used both from build() and NetworkCacheImage.getFile()
  // (for places where the cached file is needed directly without the widget).
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

    return originalUrl;
  }

  // CDN proxy (weserv.nl)

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

  // High-quality cache manager (no compression and no resizing) — singleton,
  // because it always works with the same parameters (without resizing).

  static final CacheManager _highQualityCacheManager = CacheManager(
    Config(
      'soundCenterHQImageCache',
      stalePeriod: const Duration(days: 5),
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: 'hqImageCacheInfo'),
      fileService: HttpFileService(),
    ),
  );

  // Low-quality cache managers, with one instance per (width, quality) combination.
  // This way, memCacheSize/quality passed to the widget actually affects the file
  // cached on disk as well (the previous version ignored this because a single
  // fixed instance with width=400 was used for everything).

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

  // Direct access to the cached file without rendering the widget — for places
  // where only the raw File is needed (e.g. for sharing, setting it as a
  // notification image, or any other use outside the widget tree).
  //
  // Correct replacement for the previous pattern:
  //   NetworkCacheImage.customCacheManager.getSingleFile(url)
  // which always returned a low-quality file without using the proxy and ignored
  // the user's settings (AppSettingStorage.getImageQualityState).
  //
  // This method follows the same path as build(): check the quality setting,
  // construct the proxy or original URL accordingly, and get the file from the
  // appropriate cache manager for that quality/size.

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
      // Same fallback logic as the widget: if the proxy fails, use the original URL.
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
      placeholder: (_, _) => const Loading(),
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
          placeholder: (_, _) => const Loading(),
          errorWidget: (_, _, _) => _fallback(),
        );
      },
    );

    // ImageFiltered is only created when an actual blur is requested;
    // in the previous version, an extra layer was always added to the
    // compositing tree, even when blur=0.
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

/// 2. HTTP service with fallback + compression

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

      // weserv has already performed the resizing/compression; decoding again
      // just to discard the result wastes CPU on the most frequently used path.
      // Return the bytes as-is.
      if (isProxy) {
        return _MemoryResponse(bytes, response.validTill, 'jpg');
      }

      // This is the non-proxy path (e.g. a retry with originalUrl); here we
      // actually need to perform the resizing/compression ourselves, so decoding
      // is necessary.
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw Exception('failed to decode image bytes for $url');
      }
      final Uint8List compressed = _compress(decoded);
      return _MemoryResponse(compressed, response.validTill, 'jpg');
    } on Exception catch (e) {
      debugPrint('Download failed ($url) → $e');
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

/// 3. In-memory response (without writing to disk)

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
