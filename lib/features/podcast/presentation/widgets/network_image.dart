import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return url != null
        ? FastCachedImage(
            url: url!,
            width: size,
            height: size,
            fit: fit,
            filterQuality: FilterQuality.high,
            loadingBuilder: (context, progress) {
              return Loading();
            },
            errorBuilder: (ctx, ob, s) {
              return SizedBox(
                width: size,
                height: size,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              );
            },
          )
        : SizedBox(
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
