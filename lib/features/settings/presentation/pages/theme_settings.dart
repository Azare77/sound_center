import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/shared/theme/themes.dart';

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key});

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  late final SettingsRepositoryImp settingsRepository;
  late AppThemes theme;

  @override
  void initState() {
    super.initState();
    settingsRepository = SettingsRepositoryImp();
    theme = settingsRepository.getTheme();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingBloc bloc = BlocProvider.of<SettingBloc>(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
        child: RadioGroup<AppThemes>(
          onChanged: (v) {
            setState(() => theme = v!);
            bloc.add(ChangeTheme(theme));
          },
          groupValue: theme,
          child: Column(
            mainAxisSize: .min,
            children: [
              InkWell(
                onTap: () {
                  setState(() => theme = AppThemes.dark);
                  bloc.add(ChangeTheme(theme));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Radio<AppThemes>(value: AppThemes.dark),
                      Text("Dark"),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() => theme = AppThemes.green);
                  bloc.add(ChangeTheme(theme));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Radio<AppThemes>(value: AppThemes.green),
                      Text("Green"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
