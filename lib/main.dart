import 'dart:async';
import 'dart:io';

import 'package:android_media_store/android_media_store.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:open_with_app/open_with_app.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/services/audio_handler.dart';
import 'package:sound_center/core/services/download_manager.dart';
import 'package:sound_center/core_view/home.dart';
import 'package:sound_center/database/shared_preferences/app_setting_storage.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/features/settings/presentation/pages/backup_dialog.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:toastification/toastification.dart';

late final AudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? initialBackupPath;
  if (Platform.isAndroid || Platform.isIOS) {
    final openWithApp = OpenWithApp();
    try {
      initialBackupPath = await openWithApp.getInitialFile();
    } catch (e, st) {
      debugPrint('❌ getInitialFile failed: $e\n$st');
    }
  }

  await Storage.instance.init();
  await _init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocalBloc()),
        BlocProvider(create: (_) => PodcastBloc()),
        BlocProvider(create: (_) => SettingBloc()),
        BlocProvider(create: (_) => StreamBloc()),
        BlocProvider(create: (_) => CloudBloc()),
      ],
      child: MyApp(initialBackupPath: initialBackupPath),
    ),
  );
}

Future<void> _init() async {
  try {
    if (!(kIsWeb || Platform.isWindows)) {
      bool isNotificationPersist = AppSettingStorage.getNotificationState();
      audioHandler = await AudioService.init(
        builder: () => JustAudioNotificationHandler(),
        config: AudioServiceConfig(
          androidNotificationIcon: "mipmap/ic_notification",
          androidNotificationChannelId: 'app.soundcenter.player.channel.audio',
          androidNotificationChannelName: 'Playback',
          androidNotificationChannelDescription: "Show Current player status",
          androidNotificationOngoing: !isNotificationPersist,
          androidStopForegroundOnPause: !isNotificationPersist,
          fastForwardInterval: Duration(seconds: 30),
          rewindInterval: Duration(seconds: 10),
        ),
      );
    }
    if (Platform.isLinux) {
      JustAudioMediaKit.ensureInitialized();
    }
    await AndroidMediaStore.ensureInitialized();
    await DownloadManager.init();
    debugPrint('✅ _init() completed successfully');
  } catch (e, st) {
    debugPrint('❌ Error in _init(): $e\n$st');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialBackupPath});

  final String? initialBackupPath;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final OpenWithApp _openWithApp = OpenWithApp();
  StreamSubscription<String>? _backupSub;

  @override
  void initState() {
    super.initState();
    if (Platform.isLinux) return;
    if (widget.initialBackupPath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openBackup(widget.initialBackupPath!);
      });
    }

    _backupSub = _openWithApp.getFileStream().listen(_openBackup);
  }

  @override
  void dispose() {
    _backupSub?.cancel();
    super.dispose();
  }

  void _openBackup(String path) {
    print(path);
    BackupDialog dialog = BackupDialog();
    dialog.restoreFromFile(context, path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (BuildContext context, state) {
        DownloadManager.setupNotification();
        final currentTheme = ThemeManager.current;
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
              ...GlobalMaterialLocalizations.delegates,
            ],
            title: "Sound Center",
            theme: ThemeManager.getThemeData(currentTheme),
            darkTheme: ThemeManager.getThemeData(currentTheme),
            themeMode: themMode,
            home: Home(),
          ),
        );
      },
    );
  }
}
