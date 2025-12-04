import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/download_manager.dart';
import 'package:sound_center/core_view/home.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:toastification/toastification.dart';

late final AudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          androidNotificationIcon: "mipmap/ic_notification",
          androidNotificationChannelId: 'app.soundcenter.player.channel.audio',
          androidNotificationChannelName: 'Playback',
          androidNotificationChannelDescription: "Show Current player status",
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocalBloc()),
        BlocProvider(create: (_) => PodcastBloc()),
        BlocProvider(create: (_) => SettingBloc()),
      ],
      child: BlocBuilder<SettingBloc, SettingState>(
        builder: (BuildContext context, state) {
          final currentTheme = ThemeManager.current.themeData;
          final isDarkMode = currentTheme.brightness == Brightness.dark;
          ThemeMode themMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
          return ToastificationWrapper(
            child: MaterialApp(
              navigatorKey: NAVIGATOR_KEY,
              debugShowCheckedModeBanner: false,
              locale: state.locale,
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              title: "Sound Center",
              theme: ThemeManager.current.themeData,
              darkTheme: ThemeManager.current.themeData,
              themeMode: themMode,
              home: Home(),
            ),
          );
        },
      ),
    );
  }
}
