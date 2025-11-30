import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/features/settings/presentation/pages/theme_designer.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key});

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  late final SettingsRepositoryImp settingsRepository;
  late String theme;

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
    return BlocListener<SettingBloc, SettingState>(
      listener: (_, _) => setState(() {
        theme = ThemeManager.current.id;
      }),
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
          child: RadioGroup<String>(
            onChanged: (v) {
              setState(() => theme = v!);
              bloc.add(ChangeTheme(theme));
            },
            groupValue: theme,
            child: Column(
              mainAxisSize: .min,
              children: [
                ...ThemeManager.allThemes.map((item) {
                  final id = item.id;
                  return InkWell(
                    onTap: () {
                      setState(() => theme = id);
                      bloc.add(ChangeTheme(theme));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Radio<String>(value: id),
                          Expanded(
                            child: Text(
                              Intl.message(id, name: id),
                              maxLines: 1,
                            ),
                          ),
                          if (ThemeManager.getCustomTheme(id) != null)
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ThemeDesigner(themeName: id),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit_rounded),
                            ),
                          if (ThemeManager.getCustomTheme(id) != null)
                            IconButton(
                              onPressed: () {
                                ThemeManager.removeCustomTheme(id);
                                setState(() {});
                              },
                              icon: Icon(Icons.delete_rounded),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: Text(S.of(context).createNewTheme),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ThemeDesigner()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
