import 'package:flutter/material.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class SourceTemplate extends StatelessWidget {
  const SourceTemplate({super.key, required this.source});

  final Source source;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 5,
          crossAxisAlignment: .start,
          children: [
            item("Title", source.title),
            item("Description", source.serverDescription),
            item("Strat at", source.streamStartIso8601.toString()),

            Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                detail(Icons.person_rounded, source.listeners),
                detail(Icons.people_alt_rounded, source.listenerPeak),
                detail(Icons.info_rounded, source.genre),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget item(String title, content) {
    return Row(
      children: [
        Text("$title : "),
        Flexible(child: ScrollingText(content ?? '')),
      ],
    );
  }

  Widget detail(IconData icon, dynamic content) {
    if (content == null) return SizedBox.shrink();
    return Row(spacing: 3, children: [Icon(icon), Text(content.toString())]);
  }
}
