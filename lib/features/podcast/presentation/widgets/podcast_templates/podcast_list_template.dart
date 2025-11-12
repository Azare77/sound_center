import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/podcast_detail.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/podcast_template.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class PodcastListTemplate extends StatelessWidget {
  const PodcastListTemplate(this.podcasts, {super.key});

  final List<Item> podcasts;

  @override
  Widget build(BuildContext context) {
    if (podcasts.isEmpty)
      return Center(child: TextView(S.of(context).noPodcast));

    return ListView.builder(
      itemCount: podcasts.length,
      itemExtent: LIST_ITEM_HEIGHT,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return InkWell(
          key: Key(podcast.feedUrl!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PodcastDetail(
                  feedUrl: podcast.feedUrl!,
                  defaultImg: podcast.bestArtworkUrl,
                ),
              ),
            );
          },
          child: PodcastTemplate(podcast: podcast),
        );
      },
    );
  }
}
