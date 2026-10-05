// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/database/shared_preferences/app_setting_storage.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_repository_imp.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:sound_center/shared/widgets/toast_message.dart';

import '../../../podcast/presentation/bloc/podcast_bloc.dart';
import '../../../stream/data/repository/stream_repository_imp.dart';
import '../../../stream/presentation/bloc/stream_bloc.dart';

class BackupDialog extends StatelessWidget {
  const BackupDialog({super.key});

  void restoreFromFile(BuildContext context, String path) async {
    final content = await File(path).readAsString();
    final backup = AppBackup.fromJson(jsonDecode(content));
    await _importBackup(context, backup);
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final database = AppDatabase();

      final podcastRepo = PodcastRepositoryImp(database);
      final streamRepo = StreamRepositoryImp(database);

      final backup = AppBackup(
        version: VERSION_NUMBER,
        podcasts: await podcastRepo.getHome(),
        streams: await streamRepo.getSubscribedStreams(),
        themes: AppSettingStorage.getCustomThemes(),
        locale: AppSettingStorage.getLocale(),
        provider: AppSettingStorage.getSavedProvider(),
        providerKeys: AppSettingStorage.getPodcastIndexKeys(),
        playerStyle: AppSettingStorage.getPlayerStyle(),
      );
      final file = await createBackupFile(backup);

      if (Platform.isLinux) {
        await FilePicker.saveFile(
          fileName: file.path,
          bytes: file.readAsBytesSync(),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile(
                file.path,
                mimeType: 'application/vnd.app.soundcenter.player.scbak',
              ),
            ],
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<File> createBackupFile(AppBackup backup) async {
    final directory = await getTemporaryDirectory();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = 'soundcenter_backup_$date.scbak';

    final file = File('${directory.path}/$fileName');

    await file.writeAsString(backup.toJsonString(), flush: true);

    return file;
  }

  Future<void> _importBackup(BuildContext context, AppBackup? backup) async {
    final importResult = BackupImportResult();
    final textStyle = ThemeManager.getThemeData(
      ThemeManager.current,
    ).textTheme.bodyMedium;
    final String successful = Intl.message(
      'Backup restored successfully.',
      name: 'backupRestoredSuccessfully',
    );
    final String partial = Intl.message(
      'Backup partially restored. Some data could not be imported.',
      name: 'backupPartiallyRestoredSomeDataCouldNotBeImported',
    );
    final String fail = Intl.message(
      'Failed to restore backup.',
      name: 'failedToRestoreBackup',
    );

    try {
      if (backup == null) {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['scbak'],
        );

        if (result.isEmpty) return;

        final content = await File(result.single.path!).readAsString();
        backup = AppBackup.fromJson(jsonDecode(content));
      }

      final db = AppDatabase();
      final podcastRepo = PodcastRepositoryImp(db);
      final streamRepo = StreamRepositoryImp(db);

      final podcastBloc = context.read<PodcastBloc>();
      final streamBloc = context.read<StreamBloc>();
      final settingBloc = context.read<SettingBloc>();

      try {
        for (final podcast in backup.podcasts ?? []) {
          await podcastRepo.subscribe(podcast);
        }
        importResult.podcasts = true;
      } catch (_) {}
      podcastBloc.add(GetSubscribedPodcasts());
      try {
        for (final stream in backup.streams ?? []) {
          await streamRepo.subscribeToStream(stream);
        }
        importResult.streams = true;
      } catch (_) {}
      streamBloc.add(GetSubscribedStreams());

      try {
        final themes = (backup.themes ?? [])
            .map(_resolveThemeId)
            .whereType<AppThemeData>()
            .toList();

        if (themes.isNotEmpty) {
          await AppSettingStorage.saveCustomThemes(themes);
        }

        final keys = backup.providerKeys;

        if (keys != null && keys['key'] != null && keys['secret'] != null) {
          await AppSettingStorage.setPodcastIndexKeys(
            keys['key']!,
            keys['secret']!,
          );
        }

        if (backup.provider != null) {
          await AppSettingStorage.saveProvider(backup.provider!);
        }

        if (backup.locale != null) {
          await AppSettingStorage.saveLocale(backup.locale!);
        }

        if (backup.playerStyle != null) {
          await AppSettingStorage.savePlayerStyle(backup.playerStyle!);
        }

        importResult.settings = true;
      } catch (_) {}

      settingBloc.add(LoadSetting());

      if (importResult.isSuccess) {
        ToastMessage.showInfoMessage(title: Text(successful, style: textStyle));
      } else if (importResult.hasPartialSuccess) {
        ToastMessage.showInfoMessage(title: Text(partial, style: textStyle));
      } else {
        ToastMessage.showInfoMessage(title: Text(fail, style: textStyle));
      }
    } catch (_) {
      ToastMessage.showInfoMessage(title: Text(fail, style: textStyle));
    } finally {
      if (backup == null) Navigator.pop(context);
    }
  }

  AppThemeData? _resolveThemeId(AppThemeData theme) {
    final duplicate = ThemeManager.isEquivalent(theme);

    if (duplicate) {
      return null;
    }

    var counter = 0;
    var result = theme;

    while (ThemeManager.getTheme(result.id) != null) {
      result = theme.copyWith(id: '${theme.id}-${++counter}');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
        child: Column(
          mainAxisSize: .min,
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => _exportData(context),
              child: Text(S.of(context).exportData),
            ),
            TextButton(
              onPressed: () => _importBackup(context, null),
              child: Text(S.of(context).importData),
            ),
          ],
        ),
      ),
    );
  }
}

class BackupImportResult {
  bool podcasts = false;
  bool streams = false;
  bool settings = false;

  bool get isSuccess => podcasts && streams && settings;

  bool get hasPartialSuccess => podcasts || streams || settings;
}

class AppBackup {
  final int? version;
  final List<SubscriptionEntity>? podcasts;
  final List<StreamSubEntity>? streams;
  final List<AppThemeData>? themes;
  final Locale? locale;
  final PodcastProvider? provider;
  final PlayerStyle? playerStyle;
  final Map<String, String>? providerKeys;

  AppBackup({
    this.version,
    this.podcasts,
    this.streams,
    this.themes,
    this.locale,
    this.provider,
    this.playerStyle,
    this.providerKeys,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'podcasts': podcasts?.map((e) => e.toJson()).toList(),
        'streams': streams?.map((e) => e.toJson()).toList(),
        'themes': themes?.map((e) => e.toJsonForStorage()).toList(),
        'locale': locale?.languageCode,
        'provider': provider?.name,
        'providerKeys': providerKeys,
        'playerStyle': playerStyle?.name,
      },
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory AppBackup.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return AppBackup(
      version: json['version'] as int?,

      podcasts: (data['podcasts'] as List?)
          ?.map((e) => SubscriptionEntity.fromJson(e))
          .toList(),

      streams: (data['streams'] as List?)
          ?.map((e) => StreamSubEntity.fromJson(e))
          .toList(),

      themes: (data['themes'] as List?)
          ?.map((e) => AppThemeData.fromJsonForStorage(e))
          .toList(),

      locale: data['locale'] != null ? Locale(data['locale'] as String) : null,

      provider: data['provider'] != null
          ? PodcastProvider.values.firstWhereOrNull(
              (e) => e.name == data['provider'],
            )
          : null,

      playerStyle: data['playerStyle'] != null
          ? PlayerStyle.values.firstWhereOrNull(
              (e) => e.name == data['playerStyle'],
            )
          : null,

      providerKeys: data['providerKeys'] != null
          ? Map<String, String>.from(data['providerKeys'])
          : null,
    );
  }
}
