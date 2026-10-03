import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/generated/l10n.dart';

class PlaylistTemplate extends StatelessWidget {
  const PlaylistTemplate({super.key, required this.item});

  final PlaylistEntity item;

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
          // --- تصویر ---
          SizedBox(
            width: size,
            height: size,
            child: Hero(
              tag: item.title,
              child: Icon(Icons.queue_music_rounded, size: size - 10),
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
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      "${S.of(context).tracks} : ${item.itemCount.toString()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: infoTextStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(AudioUtil.convertTime(item.totalDuration), style: infoTextStyle),
        ],
      ),
    );
  }
}
