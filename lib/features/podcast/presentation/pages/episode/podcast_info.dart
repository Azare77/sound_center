import 'package:flutter/cupertino.dart';
import 'package:sound_center/shared/widgets/html_parser.dart';

class PodcastInfo extends StatelessWidget {
  const PodcastInfo({super.key, required this.info});

  final String info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: HtmlBuilder(source: info),
      ),
    );
  }
}
