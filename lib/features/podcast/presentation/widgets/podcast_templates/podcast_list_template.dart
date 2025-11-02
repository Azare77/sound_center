import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/features/podcast/presentation/pages/episode/podcast_detail.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/podcast_template.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class PodcastListTemplate extends StatelessWidget {
  PodcastListTemplate(this.podcasts, {super.key});

  final List<Item> podcasts;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (podcasts.isEmpty) return const Center(child: TextView("NO Podcast!!"));

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: DraggableScrollbar.rrect(
        controller: _scrollController,
        backgroundColor: Colors.blueAccent,
        labelTextBuilder: (offset) {
          final itemIndex = (offset / LIST_ITEM_HEIGHT).floor();
          if (itemIndex < 0 || itemIndex >= podcasts.length) {
            return const Text('');
          }
          final String title = podcasts[itemIndex].trackName ?? '';
          final label = title.isNotEmpty ? title[0].toUpperCase() : '#';
          return Text(label);
        },
        child: ListView.builder(
          itemCount: podcasts.length,
          controller: _scrollController,
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
        ),
      ),
    );
  }
}
