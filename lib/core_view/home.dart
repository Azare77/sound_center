import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/presentation/pages/local_audios.dart';
import 'package:sound_center/features/podcast/presentation/pages/podcast.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Sound Center"),
        actions: [
          IconButton(
            tooltip: "local",
            onPressed: () {
              setState(() {
                index = 0;
              });
            },
            icon: Icon(Icons.music_note),
          ),
          IconButton(
            tooltip: "podcast",
            onPressed: () {
              setState(() {
                index = 1;
              });
            },
            icon: Icon(Icons.podcasts_rounded),
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(
          //     Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
          //   ),
          // ),
          // IconButton(onPressed: () {}, icon: Icon(Icons.radio)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: index,
              children: [LocalAudios(), Podcast()],
            ),
          ),
        ],
      ),
    );
  }
}
