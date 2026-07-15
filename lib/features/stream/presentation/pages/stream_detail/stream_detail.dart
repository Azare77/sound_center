// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail/icecast_stream.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail/radio_browser_stream.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';

class StreamDetail extends StatefulWidget {
  const StreamDetail({super.key, required this.stream});

  final StreamSubEntity stream;

  @override
  State<StreamDetail> createState() => _StreamDetailState();
}

class _StreamDetailState extends State<StreamDetail> {
  final StreamRepositoryImp repository = StreamRepositoryImp(AppDatabase());
  bool subscribed = false;
  late String streamUrl;
  late StreamBloc bloc;

  @override
  void initState() {
    streamUrl = widget.stream.url;
    bloc = BlocProvider.of<StreamBloc>(context);
    super.initState();
  }

  Future<bool> _subscribe(StreamSubEntity sub) async {
    StreamEvent? event;
    if (subscribed) {
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (_) => const ConfirmDialog(),
          ) ??
          false;
      if (!confirmed) return false;
      event = UnSubscribeFromStream(sub);
    } else {
      event = SubscribeToStream(sub);
    }
    bloc.add(event);
    setState(() => subscribed = !subscribed);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = widget.stream.fullData != null
        ? RadioStreamView(
            station: widget.stream.fullData!,
            subscribe: _subscribe,
            repository: repository,
          )
        : IcecastStreamView(
            streamUrl: streamUrl,
            subscribe: _subscribe,
            repository: repository,
          );
    return Scaffold(
      appBar: widget.stream.fullData != null ? null : AppBar(),
      body: Column(
        children: [
          Expanded(child: content),
          CurrentMedia(),
        ],
      ),
    );
  }
}
