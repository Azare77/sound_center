import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class NetworkCacheImage extends StatelessWidget {
  const NetworkCacheImage({
    super.key,
    required this.url,
    this.size = 50,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double? size;
  final BoxFit fit;

  // یک بار در کل اپلیکیشن تعریف بشه (مثلاً در main.dart یا یک فایل config)
  static final customCacheManager = CacheManager(
    Config(
      'soundCenterImageCache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 1000,
      repo: JsonCacheInfoRepository(databaseName: 'imageCacheInfo'),
      fileService: HttpFileService(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _fallback();
    }
    return CachedNetworkImage(
      imageUrl: url!,
      cacheManager: customCacheManager,
      width: size,
      height: size,
      fit: fit,
      memCacheWidth: 1024,
      memCacheHeight: 1024,
      filterQuality: FilterQuality.high,
      placeholder: (context, url) => const Loading(),
      errorWidget: (context, url, error) => _fallback(),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _fallback() {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
