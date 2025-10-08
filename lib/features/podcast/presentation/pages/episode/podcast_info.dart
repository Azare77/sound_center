import 'package:flutter/cupertino.dart';

class PodcastInfo extends StatelessWidget {
  const PodcastInfo({super.key, required this.info});

  final String info;

  @override
  Widget build(BuildContext context) {
    return Text(info);
  }
}
