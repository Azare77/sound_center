import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';

class SubscribeTemplate extends StatelessWidget {
  const SubscribeTemplate({super.key, required this.podcast});

  final SubscriptionEntity podcast;

  @override
  Widget build(BuildContext context) {
    return
    // Card(
    // color: Color(0xFF082041),
    // child:
    Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Expanded(
            child: Badge(
              label: SizedBox.shrink(),
              backgroundColor: Colors.red,
              isLabelVisible: podcast.haveNewEpisode,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkCacheImage(
                  url: podcast.artworkUrl,
                  size: null,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Text(podcast.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
    // );
  }
}
