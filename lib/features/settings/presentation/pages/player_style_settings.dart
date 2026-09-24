import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/generated/l10n.dart';

class PlayerStyleSettings extends StatefulWidget {
  const PlayerStyleSettings({super.key});

  @override
  State<PlayerStyleSettings> createState() => _PlayerStyleSettingsState();
}

class _PlayerStyleSettingsState extends State<PlayerStyleSettings> {
  late final SettingsRepositoryImp settingsRepository;
  late PlayerStyle style;
  late final SettingBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<SettingBloc>(context);
    settingsRepository = SettingsRepositoryImp();
    style = settingsRepository.getPlayerStyle();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
          child: RadioGroup<PlayerStyle>(
            onChanged: (v) {
              setState(() => style = v!);
              submit(style);
            },
            groupValue: style,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                radioItem(PlayerStyle.solid, S.of(context).solidColor),
                radioItem(PlayerStyle.blur, S.of(context).blurCover),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget radioItem(PlayerStyle style, String languageName) {
    return GestureDetector(
      onTap: () {
        setState(() => this.style = style);
        submit(style);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<PlayerStyle>(value: style),
            Expanded(child: Text(languageName)),
          ],
        ),
      ),
    );
  }

  void submit(PlayerStyle style) {
    settingsRepository.setPlayerStyle(style);
  }
}
