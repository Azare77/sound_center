import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlBuilder extends StatelessWidget {
  const HtmlBuilder({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: source,
      style: {"body": Style(fontSize: FontSize(15.0))},
      onLinkTap: (String? link, _, _) async {
        if (link == null) return;
        final Uri url = Uri.parse(link);
        launchUrl(url, mode: LaunchMode.externalApplication);
      },
    );
  }
}
