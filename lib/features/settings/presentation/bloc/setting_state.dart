part of 'setting_bloc.dart';

class SettingState {
  final Locale locale;

  const SettingState(this.locale);

  SettingState setLocale(Locale locale) {
    return SettingState(locale);
  }
}
