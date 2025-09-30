import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
// import 'package:metadata_god/metadata_god.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core_view/home.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';

late final AudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  JustAudioMediaKit.ensureInitialized();
  await Storage.instance.init();
  if (!(kIsWeb || Platform.isWindows)) {
    audioHandler = await AudioService.init(
      builder: () => JustAudioNotificationHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.example.sound_center.channel.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
      ),
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LocalBloc()),
          BlocProvider(create: (_) => PodcastBloc()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sound Center',
          theme: ThemeData(
            fontFamily: "Vazir",
            brightness: Brightness.dark,
            colorScheme: ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xFFD0BCFF),
              onPrimary: Color(0xFF27734F),
              secondary: Color(0xFFCCC2DC),
              onSecondary: Color(0xFF332D41),
              error: Color(0xFFF2B8B5),
              onError: Color(0xFF601410),
              surface: Color(0xFF141218),
              onSurface: Color(0xFFE6E0E9),
            ),
          ),
          home: const MyHomePage(title: 'Sound Center'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Home();
  }
}
