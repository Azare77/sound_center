import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/presentation/pages/local_audios.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Sound Center"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.phone_android_rounded)),
          IconButton(onPressed: () {}, icon: Icon(Icons.podcasts_rounded)),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.radio)),
        ],
      ),
      body: Column(children: [Expanded(child: LocalAudios())]),
    );
  }
}
