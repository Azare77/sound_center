import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/description.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PodcastInfo extends StatelessWidget {
  const PodcastInfo({
    super.key,
    required this.subscribed,
    required this.subscribe,
    this.url,
    this.podcast,
  });

  final bool subscribed;
  final Function() subscribe;
  final String? url;
  final Podcast? podcast;

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
            title: podcast == null
                ? SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(top: toolbar),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        ScrollingText(
                          podcast!.title ?? "",
                          style: TextStyle(color: Colors.white),
                        ),
                        if (t == 1)
                          Row(
                            spacing: 5,
                            children: [
                              ElevatedButton(
                                onPressed: subscribe,
                                child: Text(
                                  subscribed
                                      ? S.of(context).unsubscribe
                                      : S.of(context).subscribe,
                                ),
                              ),
                              if (podcast!.description != null)
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Description(
                                        description: podcast!.description!,
                                      ),
                                    );
                                  },
                                  child: Text(S.of(context).description),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: url ?? "",
                  child: NetworkCacheImage(
                    url: url,
                    size: visibleHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  opacity: podcast != null ? t * 0.6 : 0,
                  duration: Duration(milliseconds: 500),
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
