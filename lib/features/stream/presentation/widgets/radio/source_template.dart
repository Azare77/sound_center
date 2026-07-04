import 'package:flutter/material.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class SourceTemplate extends StatelessWidget {
  const SourceTemplate({super.key, required this.source});

  final Source source;

  @override
  Widget build(BuildContext context) {
    String time;
    if (source.streamStartIso8601 != null) {
      time = source.streamStartIso8601.toString();
    } else {
      time = source.streamStart ?? '';
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: .start,
          children: [
            item(S.of(context).title, source.title),
            item(S.of(context).description, source.serverDescription),
            item(S.of(context).startedAt, time),
            Divider(),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                detail(Icons.person_rounded, source.listeners),
                detail(Icons.people_alt_rounded, source.listenerPeak),
                detail(Icons.mic_rounded, source.genre),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget item(String title, content) {
    return Row(
      mainAxisSize: .min,
      children: [
        Text("$title : "),
        Flexible(child: ScrollingText(content ?? '')),
      ],
    );
  }

  Widget detail(IconData icon, dynamic content) {
    if (content == null) return SizedBox.shrink();
    return Row(
      mainAxisSize: .min,
      spacing: 3,
      children: [Icon(icon), ScrollingText(content.toString())],
    );
  }
}
