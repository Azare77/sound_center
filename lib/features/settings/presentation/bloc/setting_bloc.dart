import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/shared/theme/themes.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingState(Locale("en"), AppThemes.dark)) {
    SettingsRepositoryImp settingsRepository = SettingsRepositoryImp();

    on<ChangeLocale>((event, emit) {
      emit(state.setLocale(event.locale));
      settingsRepository.setLocale(event.locale);
    });
    on<ChangeTheme>((event, emit) {
      AppTheme.current = event.theme == AppThemes.dark
          ? DarkTheme()
          : GreenTheme();
      settingsRepository.setTheme(event.theme.name);
      emit(state.setTheme(event.theme));
    });
    on<LoadSetting>((event, emit) {
      Locale savedLocale = settingsRepository.getLocale();
      AppThemes savedTheme = settingsRepository.getTheme();
      AppTheme.current = savedTheme == AppThemes.dark
          ? DarkTheme()
          : GreenTheme();
      emit(SettingState(savedLocale, savedTheme));
    });
    add(LoadSetting());
  }
}
