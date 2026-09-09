import 'package:material_ui/material_ui.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class CloudItemTemplate extends StatelessWidget {
  const CloudItemTemplate({super.key, this.item});

  final double size = 50;
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    if (item is TrackSearchResult || item is PlaylistSearchResult) {
      return ListTile(
        leading: SizedBox(
          width: size,
          child: Hero(
            tag: item.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: NetworkCacheImage(
                url: item.artworkUrl.toString(),
                fit: item.artworkUrl != null ? BoxFit.cover : BoxFit.scaleDown,
              ),
            ),
          ),
        ),
        title: Text(item.title, maxLines: 1),
        subtitle: Text(
          item.user.fullName ?? '',
          maxLines: 1,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
      );
    }
    return SizedBox();
  }
}
