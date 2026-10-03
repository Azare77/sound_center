import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/domain/entities/categories.dart';
import 'package:sound_center/generated/l10n.dart';

class CategoryTemplate extends StatelessWidget {
  const CategoryTemplate({super.key, required this.item, required this.icon});

  final dynamic item;
  final IconData icon;

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
              tag: item.name,
              child: Icon(icon, size: size - 10),
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
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      "${S.of(context).tracks} : ${item.totalAudios.toString()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: infoTextStyle,
                    ),
                    if (item is ArtistEntity)
                      Text(
                        "${S.of(context).album} : ${item.totalAlbums.toString()}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: infoTextStyle,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Text(AudioUtil.convertTime(item.totalLength), style: infoTextStyle),
        ],
      ),
    );
  }
}
