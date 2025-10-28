import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class SubscribeTemplate extends StatelessWidget {
  const SubscribeTemplate({super.key, required this.podcast});

  final SubscriptionEntity podcast;

  @override
  Widget build(BuildContext context) {
    double size = 120;
    return Card(
      color: Color(0xFF082041),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: NetworkCacheImage(url: podcast.artworkUrl, size: size),
              ),
            ),
            ScrollingText(podcast.title),
          ],
        ),
      ),
    );
  }
}
