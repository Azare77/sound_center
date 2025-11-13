part of 'setting_bloc.dart';

sealed class SettingEvent {}

class ChangeLocale extends SettingEvent {
  Locale locale;

  ChangeLocale(this.locale);
}
