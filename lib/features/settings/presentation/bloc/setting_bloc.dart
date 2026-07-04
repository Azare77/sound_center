import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/shared/theme/themes.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingState(Locale("en"), PresetTheme.dark.name)) {
    SettingsRepositoryImp settingsRepository = SettingsRepositoryImp();

    on<ChangeLocale>((event, emit) {
      ThemeManager.setTheme(state.themeId, event.locale);
      emit(state.setLocale(event.locale));
      settingsRepository.setLocale(event.locale);
    });
    on<ChangeTheme>((event, emit) async {
      ThemeManager.setTheme(event.themeId, state.locale);
      await settingsRepository.setTheme(event.themeId);

      emit(state.setTheme(event.themeId));
    });
    on<ChangeNotificationState>((event, emit) async {
      await settingsRepository.setNotificationState(event.notificationState);
    });
    on<LoadSetting>((event, emit) {
      Locale savedLocale = settingsRepository.getLocale();
      String savedTheme = settingsRepository.getTheme();
      List<AppThemeData> customThemes = settingsRepository.getCustomThemes();
      for (final theme in customThemes) {
        ThemeManager.addCustomTheme(theme);
      }
      ThemeManager.setTheme(savedTheme, savedLocale);
      emit(SettingState(savedLocale, savedTheme));
    });
    add(LoadSetting());
  }
}
