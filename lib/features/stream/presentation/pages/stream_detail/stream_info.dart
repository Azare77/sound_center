import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_browser_api/radio_browser_api.dart' as radio;
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/network_image.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class StreamInfo extends StatefulWidget {
  const StreamInfo({
    super.key,
    required this.subscribed,
    required this.subscribe,
    required this.heroTag,
    this.url,
    this.station,
  });

  final bool subscribed;
  final Function(StreamSubEntity sub) subscribe;
  final String? url;
  final String heroTag;
  final radio.Station? station;

  @override
  State<StreamInfo> createState() => _StreamInfoState();
}

class _StreamInfoState extends State<StreamInfo> {
  bool subscribed = false;

  @override
  void didUpdateWidget(covariant StreamInfo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.subscribed != widget.subscribed) {
      subscribed = widget.subscribed;
    }
  }

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
              child: widget.station == null
                  ? SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        ScrollingText(
                          widget.station!.name,
                          style: TextStyle(color: Colors.white),
                        ),
                        if (t == 1)
                          Row(
                            spacing: 5,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final sub = StreamSubEntity.fromStation(
                                    widget.station!,
                                  );
                                  final res = await widget.subscribe.call(sub);
                                  if (!res) return;
                                  setState(() {
                                    subscribed = !subscribed;
                                  });
                                },
                                child: Text(
                                  subscribed
                                      ? S.of(context).unsubscribe
                                      : S.of(context).subscribe,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  BlocProvider.of<StreamBloc>(context).add(
                                    PlayStream(
                                      Source.fromStation(widget.station!),
                                    ),
                                  );
                                },
                                child: Text(S.of(context).play),
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
                  tag: widget.heroTag,
                  child: NetworkCacheImage(
                    url: widget.url,
                    size: visibleHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  opacity: t * 0.6,
                  duration: Duration(milliseconds: 500),
                  child: Container(color: Colors.black),
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
