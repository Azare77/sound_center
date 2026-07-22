import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/domain/repository/stream_repository.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/pages/stream_detail/stream_detail.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class DirectLinkDialog extends StatefulWidget {
  const DirectLinkDialog({super.key});

  @override
  State<DirectLinkDialog> createState() => _DirectLinkDialogState();
}

class _DirectLinkDialogState extends State<DirectLinkDialog> {
  final TextEditingController _controller = TextEditingController();
  late final StreamBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<StreamBloc>(context);
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

  void onSubmit(String url, bool direct) {
    url = url.trim();
    Navigator.pop(context);
    if (direct) {
      BlocProvider.of<StreamBloc>(context).add(StreamStaticFile(url));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StreamDetail(
            stream: StreamSubEntity(
              title: '',
              url: url,
              startAt: DateTime(1970),
              isOnline: true,
              uuid: null,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldBox(
              controller: _controller,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.go,
              maxLines: 1,
              labelText: S.of(context).urlLink,
              hintText: "https://your-stream-url.com/live",
            ),
            Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => onSubmit(_controller.text, true),
                  child: Text(S.of(context).play),
                ),
                TextButton(
                  onPressed: () => onSubmit(_controller.text, false),
                  child: Text(S.of(context).loadStream),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
