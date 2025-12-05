import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';

class LanguageSettings extends StatefulWidget {
  const LanguageSettings({super.key});

  @override
  State<LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  late final SettingsRepositoryImp settingsRepository;
  late Locale locale;
  late final SettingBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<SettingBloc>(context);
    settingsRepository = SettingsRepositoryImp();
    locale = settingsRepository.getLocale();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
          child: RadioGroup<Locale>(
            onChanged: (v) {
              setState(() => locale = v!);
              bloc.add(ChangeLocale(locale));
            },
            groupValue: locale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                radioItem(Locale("en"), "English"),
                radioItem(Locale("fa"), "فارسی"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget radioItem(Locale locale, String languageName) {
    return GestureDetector(
      onTap: () {
        setState(() => this.locale = locale);
        bloc.add(ChangeLocale(locale));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<Locale>(value: locale),
            Expanded(child: Text(languageName)),
          ],
        ),
      ),
    );
  }
}
