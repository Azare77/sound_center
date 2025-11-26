part of 'setting_bloc.dart';

class SettingState {
  final Locale locale;
  final AppThemes theme;

  const SettingState(this.locale, this.theme);

  SettingState setLocale(Locale locale) {
    return SettingState(locale, theme);
  }

  SettingState setTheme(AppThemes theme) {
    return SettingState(locale, theme);
  }
}
