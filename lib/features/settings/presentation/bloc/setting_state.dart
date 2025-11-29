part of 'setting_bloc.dart';

class SettingState {
  final Locale locale;
  final String themeId;

  const SettingState(this.locale, this.themeId);

  SettingState setLocale(Locale locale) {
    return SettingState(locale, themeId);
  }

  SettingState setTheme(String themeId) {
    return SettingState(locale, themeId);
  }
}
