part of 'setting_bloc.dart';

sealed class SettingEvent {}

class LoadSetting extends SettingEvent {}

class ChangeLocale extends SettingEvent {
  Locale locale;

  ChangeLocale(this.locale);
}

class ChangeTheme extends SettingEvent {
  AppThemes theme;

  ChangeTheme(this.theme);
}
