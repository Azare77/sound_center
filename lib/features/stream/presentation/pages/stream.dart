import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_browser_api/radio_browser_api.dart' as radio;
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_status.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail/stream_detail.dart';
import 'package:sound_center/features/stream/presentation/widgets/radio/stream_action_menu.dart';
import 'package:sound_center/features/stream/presentation/widgets/stream_template.dart';
import 'package:sound_center/features/stream/presentation/widgets/stream_tool_bar.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:sound_center/shared/widgets/toast_message.dart';

class StreamSearchController {
  static final ValueNotifier<bool> showSearchField = ValueNotifier(true);
}

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();

  bool resetStreamPage(BuildContext context) {
    final bloc = BlocProvider.of<StreamBloc>(context);
    final status = bloc.state.status;
    StreamSearchController.showSearchField.value = false;
    if (status is! SubscribedStreams) {
      bloc.add(GetSubscribedStreams());
      return false;
    }
    return true;
  }

  void handleDeepLink(BuildContext context, Map<String, String> params) async {
    try {
      ToastMessage.showInfoMessage(
        title: Text(S.of(context).loading),
        autoCloseIn: 10,
      );
      radio.Station? station = await StreamRepositoryImp(
        AppDatabase(),
      ).loadStationInfo(params['station']!);
      if (station == null) return;
      // bloc.add(PlayStream(Source.fromStation(station)));
      await Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) =>
              StreamDetail(stream: StreamSubEntity.fromStation(station)),
        ),
      );
    } catch (_) {
      // ignore: use_build_context_synchronously
      ToastMessage.showErrorMessage(title: S.of(context).errorInLoading);
    }
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
    final bloc = BlocProvider.of<StreamBloc>(context);
    return Column(
      children: [
        StreamToolBar(),
        Expanded(
          child: BlocBuilder<StreamBloc, StreamState>(
            buildWhen: (previous, current) {
              bool notDownload =
                  current.status is! ErrorLoadStream &&
                  current.status is! StreamServer;
              return notDownload;
            },
            builder: (BuildContext context, StreamState state) {
              if (state.status is SubscribedStreams) {
                SubscribedStreams status = state.status as SubscribedStreams;
                if (status.streams.isEmpty) {
                  return Center(child: Text(S.of(context).noStream));
                }
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
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StreamDetail(stream: stream),
                            ),
                          );
                          bloc.add(GetSubscribedStreams());
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
              if (state.status is SearchStreams) {
                SearchStreams status = state.status as SearchStreams;
                if (status.streams.isEmpty) {
                  return Center(child: Text(S.of(context).noStream));
                }
                return ListView.builder(
                  itemCount: status.streams.length,
                  itemBuilder: (context, index) {
                    final stream = status.streams[index];
                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StreamDetail(stream: stream),
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
                );
              }
              if (state.status is LoadingStream) {
                return Loading();
              }
              return Center(child: Text(S.of(context).noStream));
            },
          ),
        ),
      ],
    );
  }
}
