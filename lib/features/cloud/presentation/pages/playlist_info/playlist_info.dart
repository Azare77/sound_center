import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PlaylistInfo extends StatelessWidget {
  const PlaylistInfo({super.key, this.url, required this.playlist});

  final String? url;
  final CloudPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets edgeInsets = EdgeInsets.fromViewPadding(
      WidgetsBinding.instance.platformDispatcher.views.first.padding,
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double appBarHeight = constraints.maxHeight;
        double toolbar = kToolbarHeight + edgeInsets.top;
        double visibleHeight = appBarHeight - toolbar;
        double totalExpandableRange = EXPANDED_HEIGHT - toolbar;
        double rawRatio = visibleHeight / totalExpandableRange;
        double t = rawRatio.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: FlexibleSpaceBar(
            title: Padding(
              padding: EdgeInsets.only(top: toolbar),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  ScrollingText(
                    playlist.title,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  key: ValueKey(playlist.id),
                  tag: playlist.id,
                  child: NetworkCacheImage(
                    url: url,
                    size: visibleHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                Opacity(
                  opacity: t * 0.6,
                  child: Container(
                    color: Colors.black, // opacity نرم overlay
                  ),
                ),
              ],
            ),
            titlePadding: EdgeInsetsGeometry.symmetric(
              horizontal: 5,
              vertical: 5,
            ),
            expandedTitleScale: 1,
          ),
        );
      },
    );
  }
}
