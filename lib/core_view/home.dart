import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/presentation/pages/local_audios.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(child: LocalAudios())]);
  }
}
