import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart' as radio;
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/util/text_util.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail/stream_info.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class RadioStreamView extends StatefulWidget {
  const RadioStreamView({
    super.key,
    required this.stream,
    required this.repository,
    required this.subscribe,
  });

  final StreamSubEntity stream;
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
  radio.Station? station;

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
    _init();
  }

  Future<void> _init() async {
    final res = await widget.repository.loadStationInfo(widget.stream.uuid!);
    if (res == null) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
      return;
    }
    station = res;
    _checkSubscription();
  }

  void _checkSubscription() async {
    final result = await widget.repository.isSubscribed(station!.url);
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
            child: Text(station?.name ?? widget.stream.title),
          ),
          expandedHeight: EXPANDED_HEIGHT,
          flexibleSpace: StreamInfo(
            subscribe: widget.subscribe,
            subscribed: subscribed,
            station: station,
            heroTag: widget.stream.uuid!,
            cover: widget.stream.cover,
          ),
        ),
        SliverToBoxAdapter(
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
                child: station == null
                    ? SizedBox(
                        height:
                            MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            EXPANDED_HEIGHT,
                        child: const Center(child: Loading()),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Text(S.of(context).title, style: titleStyle),
                            Text(station!.name),
                            Text(S.of(context).country, style: titleStyle),
                            Text(
                              TextUtil.getCountryName(station!.countryCode) ??
                                  '',
                            ),

                            if (station!.language != null) ...[
                              Text(S.of(context).language, style: titleStyle),
                              Text(station!.language!),
                            ],
                            if (station!.tags != null) ...[
                              Text(S.of(context).tags, style: titleStyle),
                              Text(station!.tags!),
                            ],
                            if (station!.codec != null ||
                                station!.bitrate > 0) ...[
                              Text(S.of(context).format, style: titleStyle),
                              Row(
                                children: [
                                  if (station!.codec != null)
                                    Text(
                                      station!.codec!,
                                      style: const TextStyle(
                                        fontFamily: 'VazirEn',
                                      ),
                                    ),
                                  if (station!.codec != null &&
                                      station!.bitrate > 0)
                                    Text(" - "),
                                  if (station!.bitrate > 0)
                                    Text(
                                      "${station!.bitrate} kbps",
                                      style: const TextStyle(
                                        fontFamily: 'VazirEn',
                                      ),
                                    ),
                                ],
                              ),
                            ],

                            Text(S.of(context).website, style: titleStyle),
                            InkWell(
                              onTap: () async {
                                final uri = Uri.parse(station!.url);

                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: Text(
                                station!.url,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: .spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      S.of(context).votes,
                                      style: titleStyle,
                                    ),
                                    Text(station!.votes.toString()),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      S.of(context).clicks,
                                      style: titleStyle,
                                    ),
                                    Text(station!.clickCount.toString()),
                                  ],
                                ),
                              ],
                            ),
                          ],
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
