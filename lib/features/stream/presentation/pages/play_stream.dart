import 'package:flutter/material.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_header.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_navigation.dart';

class PlayStream extends StatelessWidget {
  const PlayStream({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          spacing: 25,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 4, child: StreamHeader()),
            Expanded(flex: 2, child: StreamNavigation()),
          ],
        ),
      ),
    );
  }
}
