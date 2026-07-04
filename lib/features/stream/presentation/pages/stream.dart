import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_status.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail.dart';
import 'package:sound_center/features/stream/presentation/widgets/radio/stream_action_menu.dart';
import 'package:sound_center/features/stream/presentation/widgets/stream_template.dart';
import 'package:sound_center/features/stream/presentation/widgets/stream_tool_bar.dart';
import 'package:sound_center/generated/l10n.dart';

class StreamSearchController {
  static final ValueNotifier<bool> showSearchField = ValueNotifier(true);
}

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();

  bool resetStreamPage(BuildContext context) {
    // final bloc = BlocProvider.of<StreamBloc>(context);
    // final status = bloc.state.status;
    StreamSearchController.showSearchField.value = false;
    // if (status is! SubscribedPodcasts) {
    //   bloc.add(GetSubscribedPodcasts());
    //   return false;
    // }
    return true;
  }
}

class _StreamPageState extends State<StreamPage> {
  Completer<void>? refreshCompleter;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamToolBar(),
        Expanded(
          child: BlocBuilder<StreamBloc, StreamState>(
            buildWhen: (previous, current) {
              bool notStream = current.status is SubscribedStreams;
              return notStream;
            },
            builder: (BuildContext context, StreamState state) {
              if (state.status is SubscribedStreams) {
                SubscribedStreams status = state.status as SubscribedStreams;
                return RefreshIndicator(
                  onRefresh: () {
                    refreshCompleter = Completer<void>();
                    BlocProvider.of<StreamBloc>(
                      context,
                    ).add(CheckStreamsStatus(refreshCompleter));
                    return refreshCompleter!.future;
                  },
                  child: ListView.builder(
                    itemCount: status.streams.length,
                    itemBuilder: (context, index) {
                      final stream = status.streams[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StreamDetail(streamUrl: stream.url),
                            ),
                          );
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (_) => StreamActionMenu(stream: stream),
                          );
                        },
                        child: StreamTemplate(stats: stream),
                      );
                    },
                  ),
                );
              }
              return Center(child: Text(S.of(context).noStream));
            },
          ),
        ),
      ],
    );
  }
}
