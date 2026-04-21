import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_template.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_status.dart';
import 'package:sound_center/features/stream/presentation/widgets/radio/source_template.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class StreamDetail extends StatefulWidget {
  const StreamDetail({super.key, required this.streamUrl});

  final String streamUrl;

  @override
  State<StreamDetail> createState() => _StreamDetailState();
}

class _StreamDetailState extends State<StreamDetail> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StreamBloc>(context).add(LoadStream(widget.streamUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<StreamBloc, StreamState>(
                builder: (BuildContext context, StreamState state) {
                  if (state.status is StreamServer) {
                    StreamServer streamInfo = state.status as StreamServer;
                    IceStats stream = streamInfo.stream.icestats;
                    final String startAt = stream.serverStartIso8601.toString();
                    return Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                if (stream.host != null)
                                  Text("Host : ${stream.host}"),
                                if (stream.serverId != null)
                                  Text("server ID : ${stream.serverId}"),
                                if (stream.location != null)
                                  Text("Location : ${stream.location}"),
                                if (stream.serverStartIso8601 != null)
                                  Text("Started At : $startAt"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: stream.source.length,
                            itemBuilder: (BuildContext context, int index) {
                              Source source = stream.source[index];
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
                  }
                  if (state.status is FileStream) {
                    AudioModel audio = (state.status as FileStream).audio;
                    return SizedBox(
                      height: LIST_ITEM_HEIGHT,
                      child: AudioTemplate(audioEntity: audio),
                    );
                  }
                  return Loading();
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
