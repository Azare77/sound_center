part of 'setting_bloc.dart';

sealed class SettingEvent {}

class LoadSetting extends SettingEvent {}

class ChangeLocale extends SettingEvent {
  Locale locale;

  ChangeLocale(this.locale);
}

class ChangeNotificationState extends SettingEvent {
  bool notificationState;

  ChangeNotificationState(this.notificationState);
}

class ChangeTheme extends SettingEvent {
  final String themeId; // مثلاً "green" یا "custom:1735689123456"

  ChangeTheme(this.themeId);
}
