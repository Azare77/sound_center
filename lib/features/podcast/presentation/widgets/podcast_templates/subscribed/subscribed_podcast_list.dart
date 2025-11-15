import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/podcast_detail.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/subscribed/subscribe_template.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class SubscribedPodcastList extends StatefulWidget {
  const SubscribedPodcastList(this.podcasts, {super.key});

  final List<SubscriptionEntity> podcasts;

  @override
  State<SubscribedPodcastList> createState() => _SubscribedPodcastListState();
}

class _SubscribedPodcastListState extends State<SubscribedPodcastList> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int count = math.max(3, MediaQuery.widthOf(context) ~/ 130);
    if (widget.podcasts.isEmpty) {
      return Center(child: TextView(S.of(context).noPodcast));
    }
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () {
        final bloc = BlocProvider.of<PodcastBloc>(context);
        bloc.add(CheckPodcastUpdates(_refreshController));
      },
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        itemCount: widget.podcasts.length,
        itemBuilder: (context, index) {
          final podcast = widget.podcasts[index];
          return InkWell(
            key: Key(podcast.feedUrl),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PodcastDetail(
                    feedUrl: podcast.feedUrl,
                    defaultImg: podcast.artworkUrl,
                    needToUpdate: podcast.haveNewEpisode,
                  ),
                ),
              );
            },
            child: SubscribeTemplate(podcast: podcast),
          );
        },
      ),
    );
  }
}
