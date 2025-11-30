// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_repository_imp.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/domain/repository/podcast_repository.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/episodes.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/podcast_info.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episode/episodes_tool_bar.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:sound_center/shared/widgets/toast_message.dart';

class PodcastDetail extends StatefulWidget {
  const PodcastDetail({
    super.key,
    required this.feedUrl,
    this.needToUpdate = false,
    this.defaultImg,
  });

  final String feedUrl;
  final bool needToUpdate;
  final String? defaultImg;

  @override
  State<PodcastDetail> createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  final PodcastRepositoryImp repository = PodcastRepositoryImp(AppDatabase());
  bool subscribed = false;
  bool toolbarCollapsed = false;
  Podcast? podcast;
  List<Episode> episodes = [];
  String? image;
  final ScrollController _sliverScrollController = ScrollController();

  void _init({bool retry = true}) async {
    try {
      subscribed = await repository.isSubscribed(widget.feedUrl);
      podcast = await repository.loadPodcastInfo(widget.feedUrl);

      if (podcast != null) {
        episodes = podcast!.episodes;
        sort(PodcastOrder.NEWEST);
        image ??= podcast!.image;
        if (subscribed) _update();
      }
    } catch (_) {
      podcast = null;
    } finally {
      if (podcast == null && mounted) {
        if (retry) {
          ToastMessage.showErrorMessage(
            context: context,
            title: S.of(context).loadFail,
          );
          _init(retry: false);
        } else {
          Navigator.pop(context);
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    image = widget.defaultImg;
    double totalExpandableRange = EXPANDED_HEIGHT - kToolbarHeight;
    _sliverScrollController.addListener(() {
      bool hasClient = _sliverScrollController.hasClients;
      bool isOffsetBigger =
          _sliverScrollController.offset > totalExpandableRange;
      setState(() {
        if (!toolbarCollapsed && hasClient && isOffsetBigger) {
          toolbarCollapsed = true;
        } else if (toolbarCollapsed && hasClient && !isOffsetBigger) {
          toolbarCollapsed = false;
        }
      });
    });
    _init();
  }

  @override
  void dispose() {
    _sliverScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _sliverScrollController,
              slivers: [
                SliverAppBar(
                  toolbarHeight: kToolbarHeight,
                  elevation: 2,
                  shadowColor: themeData.appBarTheme.shadowColor,
                  backgroundColor: themeData.appBarTheme.backgroundColor,
                  pinned: true,
                  floating: false,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    color: toolbarCollapsed
                        ? themeData.iconTheme.color
                        : Colors.white,
                  ),
                  title: AnimatedOpacity(
                    opacity: toolbarCollapsed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(podcast?.title ?? ""),
                  ),
                  expandedHeight: EXPANDED_HEIGHT,
                  flexibleSpace: PodcastInfo(
                    subscribe: _subscribe,
                    subscribed: subscribed,
                    podcast: podcast,
                    url: image,
                  ),
                ),
                if (podcast != null)
                  SliverPinnedHeader(
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Focus(
                        onFocusChange: (f) async {
                          if (f) {
                            final offset = _sliverScrollController.offset;
                            for (int i = 0; i <= 500; i++) {
                              _sliverScrollController.jumpTo(offset);
                              await Future.delayed(Duration(milliseconds: 1));
                            }
                          }
                        },
                        child: EpisodesToolBar(
                          onChange: filter,
                          onOrderChange: sort,
                        ),
                      ),
                    ),
                  ),
                podcast == null
                    ? SliverFillRemaining(child: Loading())
                    : Episodes(
                        feedUrl: widget.feedUrl,
                        episodes: episodes,
                        bestImageUrl: image,
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
    final sub = SubscriptionEntity.fromPodcast(widget.feedUrl, podcast!);
    PodcastEvent? event;
    if (subscribed) {
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (_) => const ConfirmDialog(),
          ) ??
          false;
      if (!confirmed) return;
      event = UnsubscribeFromPodcast(sub.feedUrl);
    } else {
      event = SubscribeToPodcast(sub);
    }
    BlocProvider.of<PodcastBloc>(context).add(event);
    setState(() => subscribed = !subscribed);
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

  void filter(String name) {
    name = name.trim().toLowerCase();
    if (name.isEmpty) {
      episodes = podcast?.episodes ?? [];
    } else {
      episodes = podcast!.episodes
          .where((item) => item.title.toLowerCase().contains(name))
          .toList();
    }
    setState(() {});
  }

  void sort(PodcastOrder order) {
    episodes.sort((a, b) {
      switch (order) {
        case PodcastOrder.AZ:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());

        case PodcastOrder.ZA:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());

        case PodcastOrder.NEWEST:
          final aDate = a.publicationDate ?? DateTime(1970);
          final bDate = b.publicationDate ?? DateTime(1970);
          return bDate.compareTo(aDate);

        case PodcastOrder.OLDEST:
          final aDate = a.publicationDate ?? DateTime(1970);
          final bDate = b.publicationDate ?? DateTime(1970);
          return aDate.compareTo(bDate);
      }
    });
    setState(() {});
  }
}

class SliverPinnedHeader extends SingleChildRenderObjectWidget {
  const SliverPinnedHeader({super.key, required Widget super.child});

  @override
  RenderSliverPinnedHeader createRenderObject(BuildContext context) {
    return RenderSliverPinnedHeader();
  }
}

class RenderSliverPinnedHeader extends RenderSliverSingleBoxAdapter {
  @override
  void performLayout() {
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final paintedChildExtent = min(
      childExtent,
      constraints.remainingPaintExtent - constraints.overlap,
    );
    geometry = SliverGeometry(
      paintExtent: paintedChildExtent,
      maxPaintExtent: childExtent,
      maxScrollObstructionExtent: childExtent,
      paintOrigin: constraints.overlap,
      scrollExtent: childExtent,
      layoutExtent: max(0.0, paintedChildExtent - constraints.scrollOffset),
      hasVisualOverflow: paintedChildExtent < childExtent,
    );
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    return 0;
  }
}
