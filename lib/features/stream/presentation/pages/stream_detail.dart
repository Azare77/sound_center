// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_status.dart';
import 'package:sound_center/features/stream/presentation/widgets/radio/source_template.dart';
import 'package:sound_center/features/stream/presentation/widgets/radio/stream_name_dialog.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/button.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';
import 'package:sound_center/shared/widgets/loading.dart';
import 'package:sound_center/shared/widgets/toast_message.dart';

class StreamDetail extends StatefulWidget {
  const StreamDetail({super.key, required this.streamUrl});

  final String streamUrl;

  @override
  State<StreamDetail> createState() => _StreamDetailState();
}

class _StreamDetailState extends State<StreamDetail> {
  final StreamRepositoryImp repository = StreamRepositoryImp(AppDatabase());
  bool subscribed = false;
  IceStats? stream;

  void _init() async {
    try {
      subscribed = await repository.isSubscribed(widget.streamUrl);
      final info = await repository.loadIcecastStream(widget.streamUrl);
      if (info != null) {
        stream = info.icestats;
        if (subscribed) {
          final info = await repository.getSubscribedStream(widget.streamUrl);
          stream!.title = info.title;
        }
      }
    } catch (_) {
      stream = null;
    } finally {
      if (stream == null && mounted) {
        ToastMessage.showErrorMessage(
          context: context,
          title: S.of(context).linkIsWrongOrServerIsStopped,
        );
        if (mounted) Navigator.pop(context);
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StreamBloc>(context).add(LoadStream(widget.streamUrl));
    _init();
  }

  void _subscribe() async {
    final sub = StreamSubEntity.fromIcecast(stream!);
    StreamEvent? event;
    if (subscribed) {
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (_) => const ConfirmDialog(),
          ) ??
          false;
      if (!confirmed) return;
      event = UnSubscribeFromStream(sub);
    } else {
      event = SubscribeToStream(sub);
    }
    BlocProvider.of<StreamBloc>(context).add(event);
    setState(() => subscribed = !subscribed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stream?.title ?? '')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<StreamBloc, StreamState>(
                buildWhen: (old, current) {
                  return current.status is StreamServer;
                },
                builder: (BuildContext context, state) {
                  if (stream == null) return Loading();
                  if (state.status is StreamServer) {
                    final info = state.status as StreamServer;
                    stream!.source = info.stream.icestats.source;
                  }
                  String? time;
                  if (stream!.serverStartIso8601 != null) {
                    time = stream!.serverStartIso8601.toString();
                  } else {
                    time = stream!.serverStart;
                  }
                  return Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            spacing: 2,
                            crossAxisAlignment: .start,
                            children: [
                              if (stream!.title != null)
                                Text(
                                  "${S.of(context).title} : ${stream!.title}",
                                ),
                              if (stream!.host != null)
                                Text("${S.of(context).host} : ${stream!.host}"),
                              if (stream!.serverId != null)
                                Text(
                                  "${S.of(context).serverId} : ${stream!.serverId}",
                                ),
                              if (stream!.location != null)
                                Text(
                                  "${S.of(context).location} : ${stream!.location}",
                                ),
                              if (stream!.admin != null)
                                Text(
                                  "${S.of(context).adminInfo} : ${stream!.admin}",
                                ),
                              if (time != null)
                                Text("${S.of(context).startedAt} : $time"),
                              Divider(),
                              Button(
                                buttonText: subscribed
                                    ? S.of(context).unsubscribe
                                    : S.of(context).subscribe,
                                showLoading: false,
                                onPressed: () async {
                                  if (subscribed) {
                                    _subscribe();
                                    return;
                                  }
                                  String? name = await showDialog(
                                    context: context,
                                    builder: (_) => StreamNameDialog(),
                                  );
                                  if (name == null) return;
                                  stream!.title = name;
                                  _subscribe();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: stream!.source.length,
                          itemBuilder: (BuildContext context, int index) {
                            Source source = stream!.source[index];
                            return InkWell(
                              onTap: () {
                                BlocProvider.of<StreamBloc>(
                                  context,
                                ).add(PlayStream(source));
                              },
                              child: SourceTemplate(source: source),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          CurrentMedia(),
        ],
      ),
    );
  }
}
