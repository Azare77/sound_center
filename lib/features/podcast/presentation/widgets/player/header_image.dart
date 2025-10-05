import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';

class PodcastHeaderImage extends StatelessWidget {
  const PodcastHeaderImage({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: NetworkCacheImage(url: url, size: null),
      ),
    );
  }
}
