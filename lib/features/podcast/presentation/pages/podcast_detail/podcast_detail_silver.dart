import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_repository_imp.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episode/episode_template.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PodcastDetailSliver extends StatefulWidget {
  const PodcastDetailSliver({
    super.key,
    required this.feedUrl,
    this.needToUpdate = false,
    this.defaultImg,
  });

  final String feedUrl;
  final bool needToUpdate;
  final String? defaultImg;

  @override
  State<PodcastDetailSliver> createState() => _PodcastDetailSliverState();
}

class _PodcastDetailSliverState extends State<PodcastDetailSliver>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final PodcastRepositoryImp db = PodcastRepositoryImp(AppDatabase());
  bool subscribed = false;
  Podcast? podcast;
  final double expandedHeight = 150;

  void _init({bool retry = true}) async {
    try {
      subscribed = await db.isSubscribed(widget.feedUrl);
      podcast = await Feed.loadFeed(url: widget.feedUrl);
      if (subscribed) {
        _update();
      }
      if (podcast?.image == null) {}
    } catch (_) {
      podcast = null;
    } finally {
      if (podcast == null) {
        if (retry) {
          _init(retry: false);
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAudio = PodcastPlayerRepositoryImp().getCurrentEpisode;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: podcast == null
                ? Loading()
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: expandedHeight,
                        elevation: 2,
                        shadowColor: Color(0xFF601410),
                        backgroundColor: Color(0xff202138),
                        pinned: false,
                        floating: true,
                        centerTitle: true,
                        title: ScrollingText(podcast?.title ?? ""),
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            double appBarHeight = constraints.maxHeight;
                            double t =
                                ((appBarHeight - kToolbarHeight) /
                                        (expandedHeight - kToolbarHeight))
                                    .clamp(0.0, 1.0);

                            return FlexibleSpaceBar(
                              title: Row(
                                children: [
                                  Opacity(
                                    opacity: t,
                                    child: ElevatedButton(
                                      onPressed: _subscribe,
                                      child: Text(
                                        subscribed
                                            ? "Unsubscribe"
                                            : "Subscribe",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              background: Stack(
                                fit: StackFit.expand,
                                children: [
                                  NetworkCacheImage(
                                    url: widget.defaultImg,
                                    blur: 3,
                                  ),
                                  Container(
                                    color: Colors.black.withValues(
                                      alpha: t * 0.4,
                                    ), // opacity نرم overlay
                                  ),
                                ],
                              ),
                              expandedTitleScale: 1,
                            );
                          },
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            Episode episode = podcast!.episodes[index];
                            episode.imageUrl ??= widget.defaultImg;
                            final isCurrent =
                                currentAudio?.guid == episode.guid;
                            return Material(
                              key: ValueKey(episode.guid),
                              color: isCurrent
                                  ? Color(0x1D1BF1D8)
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {});
                                  BlocProvider.of<PodcastBloc>(context).add(
                                    PlayPodcast(
                                      episodes: podcast!.episodes,
                                      index: index,
                                    ),
                                  );
                                },
                                child: EpisodeTemplate(episode: episode),
                              ),
                            );
                          },
                          childCount: podcast!.episodes.length, // تعداد آیتم‌ها
                        ),
                      ),
                    ],
                  ),
          ),
          CurrentMedia(),
        ],
      ),
    );
  }

  void _subscribe() async {
    SubscriptionEntity sub = SubscriptionEntity.fromPodcast(
      widget.feedUrl,
      podcast!,
    );
    PodcastEvent event;
    if (subscribed) {
      event = UnsubscribeFromPodcast(sub.feedUrl);
    } else {
      event = SubscribeToPodcast(sub);
    }
    BlocProvider.of<PodcastBloc>(context).add(event);
    setState(() {
      subscribed = !subscribed;
    });
  }

  void _update() async {
    SubscriptionEntity sub = SubscriptionEntity.fromPodcast(
      widget.feedUrl,
      podcast!,
    );
    if (subscribed && widget.needToUpdate) {
      PodcastEvent event = UpdateSubscribedPodcast(sub);
      BlocProvider.of<PodcastBloc>(context).add(event);
    }
  }
}
