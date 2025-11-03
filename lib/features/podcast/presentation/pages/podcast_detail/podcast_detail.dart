import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_repository_imp.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/episodes.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/podcast_info.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class PodcastDetail extends StatefulWidget {
  const PodcastDetail({super.key, required this.feedUrl, this.defaultImg});

  final String feedUrl;
  final String? defaultImg;

  @override
  State<PodcastDetail> createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  final PodcastRepositoryImp db = PodcastRepositoryImp(AppDatabase());
  bool subscribed = false;
  Podcast? podcast;

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
    return Scaffold(
      appBar: AppBar(
        title: ScrollingText(podcast?.title ?? ""),
        actions: [
          if (podcast != null && subscribed)
            TextButton(
              onPressed: () => _subscribe(),
              child: Text("Unsubscribe"),
            ),
        ],
      ),
      body: podcast == null
          ? Loading()
          : Column(
              spacing: 5,
              children: [
                TabBar(
                  controller: _controller,
                  tabs: const [
                    Tab(text: 'Episodes'),
                    Tab(text: "Info"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      Episodes(
                        episodes: podcast!.episodes,
                        bestImageUrl: widget.defaultImg,
                      ),
                      PodcastInfo(info: podcast!.description ?? ""),
                    ],
                  ),
                ),
                if (!subscribed)
                  ElevatedButton(
                    onPressed: () => _subscribe(),
                    child: Text("Subscribe"),
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
    if (subscribed) {
      PodcastEvent event = UpdateSubscribedPodcast(sub);
      BlocProvider.of<PodcastBloc>(context).add(event);
    }
  }
}
