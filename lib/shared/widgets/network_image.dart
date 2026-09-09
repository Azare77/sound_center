// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';
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
    this.blur = 0,
    this.highQuality = false,
  });

  final String? url;
  final double? size;
  final int memCacheSize;
  final BoxFit fit;
  final double blur;
  final bool highQuality;

  // -----------------------------------------------------------------
  // اصلاح آدرس به کیفیت مشخص‌شده.
  // به‌جای خواندن از فیلد highQuality، پارامتر می‌گیرد تا هم برای
  // درخواست کیفیت پایین و هم برای چک‌کردن معادل HQ آن قابل استفاده مجدد باشد.
  // -----------------------------------------------------------------
  String _resolveUrl(String originalUrl, {required bool forHighQuality}) {
    if (!forHighQuality) return originalUrl;

    if (originalUrl.contains('-large.')) {
      return originalUrl.replaceAll('-large.', '-original.');
    } else if (originalUrl.contains('-t500x500.')) {
      return originalUrl.replaceAll('-t500x500.', '-original.');
    } else if (originalUrl.contains('-t300x300.')) {
      return originalUrl.replaceAll('-t300x300.', '-original.');
    }
    return originalUrl;
  }

  // -----------------------------------------------------------------
  // CDN‑proxy (weserv.nl)
  // -----------------------------------------------------------------
  String _proxyUrl(String originalUrl, {required bool forHighQuality}) {
    final resolved = _resolveUrl(originalUrl, forHighQuality: forHighQuality);
    if (forHighQuality) {
      return 'https://images.weserv.nl/'
          '?url=${Uri.encodeComponent(resolved)}'
          '&q=100&output=jpg';
    }
    return 'https://images.weserv.nl/'
        '?url=${Uri.encodeComponent(resolved)}'
        '&w=400&h=400&fit=cover&q=75&output=jpg';
  }

  static String _cacheKey(String resolvedUrl, {required bool isHighQuality}) =>
      'hq_${isHighQuality}_$resolvedUrl';

  // -----------------------------------------------------------------
  // کش منیجر پیش‌فرض (برای تصاویر عادی همراه با فشرده‌سازی)
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

  // -----------------------------------------------------------------
  // کش منیجر اختصاصی کیفیت بالا (بدون فشرده‌سازی و بدون تغییر ابعاد)
  // -----------------------------------------------------------------
  static final highQualityCacheManager = CacheManager(
    Config(
      'soundCenterHQImageCache',
      stalePeriod: const Duration(days: 15),
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: 'hqImageCacheInfo'),
      fileService: HttpFileService(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _fallback();

    if (highQuality) {
      // خودمون صریحاً HQ خواستیم؛ نیازی به چک اضافه نیست.
      return _buildRemote(forHighQuality: true);
    }

    // پیش از رفتن سراغ نسخهٔ فشرده، چک کن آیا نسخهٔ HQ همین تصویر
    // قبلاً روی دیسک کش شده یا نه (فقط یک I/O محلی، بدون شبکه).
    final hqResolvedUrl = _resolveUrl(url!, forHighQuality: true);
    final hqCacheKey = _cacheKey(hqResolvedUrl, isHighQuality: true);

    return FutureBuilder<FileInfo?>(
      future: highQualityCacheManager.getFileFromCache(hqCacheKey),
      builder: (context, snapshot) {
        final hqFile = snapshot.data;
        if (hqFile != null) {
          return _buildFromLocalFile(hqFile.file);
        }
        // نسخهٔ HQ کش نشده -> مسیر عادی (فشرده) طی می‌شود.
        // اگر بعداً کاربر highQuality=true رو جایی دیگه لود کنه و کش بشه،
        // دفعهٔ بعد که این ویجت rebuild بشه از همون فایل استفاده می‌کنه.
        return _buildRemote(forHighQuality: false);
      },
    );
  }

  // -----------------------------------------------------------------
  // رندر مستقیم از فایل موجود روی دیسک (بدون هیچ درخواست شبکه)
  // -----------------------------------------------------------------
  Widget _buildFromLocalFile(File file) {
    Widget image = Image.file(
      file,
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
      // اگر فایل بین لحظهٔ چک‌کردن کش و لحظهٔ رندر واقعی حذف/خراب شده باشد
      // (race condition نادر)، برمی‌گردیم به مسیر عادی شبکه.
      errorBuilder: (_, __, ___) => _buildRemote(forHighQuality: false),
    );
    if (blur > 0) {
      image = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: image,
      );
    }
    return image;
  }

  // -----------------------------------------------------------------
  // رندر از شبکه (با CDN proxy + fallback به آدرس اصلی)
  // -----------------------------------------------------------------
  Widget _buildRemote({required bool forHighQuality}) {
    final resolvedUrl = _resolveUrl(url!, forHighQuality: forHighQuality);
    final proxy = _proxyUrl(url!, forHighQuality: forHighQuality);
    final cacheManager = forHighQuality
        ? highQualityCacheManager
        : customCacheManager;
    final cacheKey = _cacheKey(resolvedUrl, isHighQuality: forHighQuality);

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: CachedNetworkImage(
        imageUrl: proxy,
        cacheManager: cacheManager,
        cacheKey: cacheKey,
        width: size,
        height: size,
        fit: fit,
        memCacheWidth: forHighQuality ? null : memCacheSize,
        memCacheHeight: forHighQuality ? null : memCacheSize,
        filterQuality: FilterQuality.high,
        placeholder: (_, _) => const Loading(),
        fadeInDuration: const Duration(milliseconds: 300),
        errorWidget: (context, _, error) {
          debugPrint('CDN failed → fallback to original: $error');
          return CachedNetworkImage(
            imageUrl: resolvedUrl,
            cacheManager: cacheManager,
            cacheKey: cacheKey,
            width: size,
            height: size,
            fit: fit,
            memCacheWidth: forHighQuality ? null : memCacheSize,
            memCacheHeight: forHighQuality ? null : memCacheSize,
            placeholder: (_, _) => const Loading(),
            errorWidget: (_, _, _) => _fallback(),
          );
        },
      ),
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
/// 2. سرویس HTTP با fallback + compress (دست‌نخورده باقی می‌ماند)
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

      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final Uint8List compressed = isProxy ? bytes : _compress(decoded);
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
