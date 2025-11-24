import 'package:flutter/material.dart';
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
              hintText: S.of(context).rssFeed,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PodcastDetail(feedUrl: _controller.text.trim()),
                  ),
                );
              },
              child: Text(S.of(context).loadPodcast),
            ),
          ],
        ),
      ),
    );
  }
}
