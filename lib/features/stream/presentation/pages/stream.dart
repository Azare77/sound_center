import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/stream/domain/repository/stream_repository.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail.dart';
import 'package:sound_center/shared/widgets/button.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = "http://192.168.1.2:8000/live";
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  StreamType detectStreamType(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('icecast') ||
        lower.contains('shoutcast') ||
        lower.endsWith('/stream') ||
        lower.endsWith('/;') ||
        lower.contains('/live') ||
        lower.contains('/radio')) {
      return StreamType.iceCast;
    } else {
      return StreamType.staticFile;
    }
  }

  void onSubmit(String url) {
    debugPrint("my log");
    log('ICY metadata received: $url', name: 'ICY_STREAM', level: 1000);
    url = url.trim();
    switch (detectStreamType(url)) {
      case StreamType.staticFile:
        BlocProvider.of<StreamBloc>(context).add(LoadStream(url));
        break;
      case StreamType.iceCast:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StreamDetail(streamUrl: url)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextFieldBox(
            controller: _controller,
            labelText: "URL",
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.go,
            autofocus: false,
            hintText: "https://your-stream-url.com/live",
            onSubmitted: onSubmit,
          ),
        ),
        Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            Button(buttonText: "Download", onPressed: () {}),
            Button(
              buttonText: "Play",
              onPressed: () {
                onSubmit(_controller.text);
              },
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<StreamBloc, StreamState>(
            builder: (BuildContext context, StreamState state) {
              return Center(child: Text("No Stream"));
            },
          ),
        ),
      ],
    );
  }
}
