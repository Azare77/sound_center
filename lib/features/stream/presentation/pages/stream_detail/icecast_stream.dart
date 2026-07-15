import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_status.dart';
import 'package:sound_center/features/stream/presentation/widgets/radio/source_template.dart';
import 'package:sound_center/features/stream/presentation/widgets/radio/stream_name_dialog.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/button.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class IcecastStreamView extends StatefulWidget {
  const IcecastStreamView({
    super.key,
    required this.streamUrl,
    required this.subscribe,
    required this.repository,
  });

  final String streamUrl;
  final StreamRepositoryImp repository;
  final Function(StreamSubEntity sub) subscribe;

  @override
  State<IcecastStreamView> createState() => _IcecastStreamViewState();
}

class _IcecastStreamViewState extends State<IcecastStreamView> {
  IceStats? stream;
  late bool subscribed;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    try {
      subscribed = await widget.repository.isSubscribed(widget.streamUrl);
      final info = await widget.repository.loadIcecastStream(widget.streamUrl);
      if (info != null) {
        stream = info.icestats;
        if (subscribed) {
          final info = await widget.repository.getSubscribedStream(
            widget.streamUrl,
          );
          stream!.title = info.title;
        }
      }
    } catch (_) {
      stream = null;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreamBloc, StreamState>(
      buildWhen: (old, current) {
        if (current.status is StreamServer) {
          StreamServer status = current.status as StreamServer;
          if (status.stream.icestats.url == stream!.url) {
            return true;
          }
        }
        return false;
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
                      Text("${S.of(context).title} : ${stream!.title}"),
                    if (stream!.host != null)
                      Text("${S.of(context).host} : ${stream!.host}"),
                    if (stream!.serverId != null)
                      Text("${S.of(context).serverId} : ${stream!.serverId}"),
                    if (stream!.location != null)
                      Text("${S.of(context).location} : ${stream!.location}"),
                    if (stream!.admin != null)
                      Text("${S.of(context).adminInfo} : ${stream!.admin}"),
                    if (time != null)
                      Text("${S.of(context).startedAt} : $time"),
                    Divider(),
                    Button(
                      buttonText: subscribed
                          ? S.of(context).unsubscribe
                          : S.of(context).subscribe,
                      showLoading: false,
                      onPressed: () async {
                        if (!subscribed) {
                          String? name = await showDialog(
                            context: context,
                            builder: (_) => StreamNameDialog(),
                          );
                          if (name == null) return;
                          stream!.title = name;
                        }
                        final sub = StreamSubEntity.fromIcecast(stream!);
                        final res = await widget.subscribe.call(sub);
                        if (!res) return;
                        setState(() {
                          subscribed = !subscribed;
                        });
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
    );
  }
}
