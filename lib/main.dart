import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/download_manager.dart';
import 'package:sound_center/core_view/home.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/shared/theme/themes.dart';

late final AudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: DarkTheme.themeData.appBarTheme.backgroundColor,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: DarkTheme.themeData.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await Storage.instance.init();
  await _init();
  runApp(const MyApp());
}

Future<void> _init() async {
  try {
    if (!(kIsWeb || Platform.isWindows)) {
      audioHandler = await AudioService.init(
        builder: () => JustAudioNotificationHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId:
              'com.example.sound_center.channel.audio',
          androidNotificationChannelName: 'Music Playback',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: false,
        ),
      );
    }
    if (Platform.isLinux) {
      JustAudioMediaKit.ensureInitialized();
    }
    await PodcastDownloader.init();
    debugPrint('✅ _init() completed successfully');
  } catch (e, st) {
    debugPrint('❌ Error in _init(): $e\n$st');
  }
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
          locale: const Locale('fa'),
          supportedLocales: const [Locale("fa"), Locale("en")],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return const Locale('en'); // fallback
          },
          title: 'Sound Center',
          theme: DarkTheme.themeData,
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
