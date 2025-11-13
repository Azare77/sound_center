import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingState(Locale("en"))) {
    SettingsRepositoryImp settingsRepository = SettingsRepositoryImp();
    on<ChangeLocale>((event, emit) {
      emit(state.setLocale(event.locale));
      settingsRepository.setLocale(event.locale);
    });
    Locale savedLocale = settingsRepository.getLocale();
    add(ChangeLocale(savedLocale));
  }
}
