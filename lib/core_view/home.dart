import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/presentation/pages/local_audios.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/order_menu.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Sound Center"),
        actions: [OrderMenu()],
      ),
      body: Column(children: [Expanded(child: LocalAudios())]),
    );
  }
}
