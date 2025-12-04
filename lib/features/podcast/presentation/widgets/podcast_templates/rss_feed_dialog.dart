import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast_detail/podcast_detail.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class RssFeedDialog extends StatefulWidget {
  const RssFeedDialog({super.key});

  @override
  State<RssFeedDialog> createState() => _RssFeedDialogState();
}

class _RssFeedDialogState extends State<RssFeedDialog> {
  final TextEditingController _controller = TextEditingController();
  late final PodcastBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<PodcastBloc>(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldBox(
              controller: _controller,
              textInputAction: TextInputAction.go,
              maxLines: 1,
              labelText: S.of(context).rssFeed,
              hintText: S.of(context).rssFeed,
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PodcastDetail(feedUrl: _controller.text.trim()),
                  ),
                );
                bloc.add(GetSubscribedPodcasts());
              },
              child: Text(S.of(context).loadPodcast),
            ),
          ],
        ),
      ),
    );
  }
}
