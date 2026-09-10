import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/core/util/date_util.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class CloudItemTemplate extends StatelessWidget {
  const CloudItemTemplate({super.key, this.item});

  final double size = 50;
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final TextStyle infoTextStyle = TextStyle(
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontSize: 13,
    );
    if (item is CloudTrack || item is CloudPlaylist) {
      return Container(
        height: LIST_ITEM_HEIGHT,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          spacing: 10,
          children: [
            // --- تصویر ---
            SizedBox(
              width: size,
              child: Hero(
                key: ValueKey(item.id),
                tag: item.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkCacheImage(
                    url: item.artworkUrl,
                    fit: item.artworkUrl != null
                        ? BoxFit.cover
                        : BoxFit.scaleDown,
                  ),
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
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisSize: .min,
                    spacing: 15,
                    children: [
                      if (item.author != null && item.author.isNotEmpty)
                        Text(
                          item.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: infoTextStyle,
                        ),
                      Text(
                        toJalali(item.createDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: infoTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(AudioUtil.convertTime(item.duration), style: infoTextStyle),
          ],
        ),
      );
    }
    return SizedBox();
  }
}
