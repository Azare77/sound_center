import 'package:flutter/material.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class StreamTemplate extends StatelessWidget {
  const StreamTemplate({super.key, required this.stats});

  final StreamSubEntity stats;
  final double size = 50;

  @override
  Widget build(BuildContext context) {
    final TextStyle infoTextStyle = TextStyle(
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontSize: 13,
    );
    return Container(
      height: LIST_ITEM_HEIGHT,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        spacing: 10,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Hero(
              tag: stats.uuid ?? stats.url,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkCacheImage(url: stats.cover),
              ),
            ),
          ),
          // --- متن‌ها ---
          Expanded(
            child: Column(
              spacing: 2,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  stats.isOnline ? "Live 🔴" : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: infoTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
