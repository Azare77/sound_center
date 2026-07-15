import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart' as radio;
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/podcast_detail.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail/stream_info.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class RadioStreamView extends StatefulWidget {
  const RadioStreamView({
    super.key,
    required this.station,
    required this.repository,
    required this.subscribe,
  });

  final radio.Station station;
  final StreamRepositoryImp repository;
  final Function(StreamSubEntity sub) subscribe;

  @override
  State<RadioStreamView> createState() => _RadioStreamViewState();
}

class _RadioStreamViewState extends State<RadioStreamView> {
  final ScrollController _sliverScrollController = ScrollController();
  bool toolbarCollapsed = false;
  bool subscribed = false;
  final titleStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

  @override
  void initState() {
    super.initState();
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
    _checkSubscription();
  }

  void _checkSubscription() async {
    final result = await widget.repository.isSubscribed(
      widget.station.urlResolved!,
    );
    if (!mounted) return;
    setState(() => subscribed = result);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return CustomScrollView(
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
            color: toolbarCollapsed ? themeData.iconTheme.color : Colors.white,
          ),
          title: AnimatedOpacity(
            opacity: toolbarCollapsed ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Text(widget.station.name),
          ),
          expandedHeight: EXPANDED_HEIGHT,
          flexibleSpace: StreamInfo(
            subscribe: widget.subscribe,
            subscribed: subscribed,
            station: widget.station,
            url: widget.station.favicon,
          ),
        ),
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
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        TextView("Station Info", style: titleStyle),
                        TextView(widget.station.name),
                        TextView(widget.station.countryCode),

                        if (widget.station.language != null)
                          TextView(widget.station.language!),

                        if (widget.station.tags != null)
                          TextView(widget.station.tags!),

                        if (widget.station.codec != null ||
                            widget.station.bitrate > 0) ...[
                          TextView("Format", style: titleStyle),
                          Row(
                            children: [
                              if (widget.station.codec != null)
                                TextView(
                                  "${widget.station.codec!} - ",
                                  style: const TextStyle(fontFamily: 'VazirEn'),
                                ),
                              if (widget.station.bitrate > 0)
                                TextView(
                                  "${widget.station.bitrate} kbps",
                                  style: const TextStyle(fontFamily: 'VazirEn'),
                                ),
                            ],
                          ),
                        ],

                        TextView("Website", style: titleStyle),
                        TextView(widget.station.url),

                        if (widget.station.favicon != null) ...[
                          TextView("Cover", style: titleStyle),
                          TextView(widget.station.favicon!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
