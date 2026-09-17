import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';
import 'package:sound_center/generated/l10n.dart';

class ImageQualitySettings extends StatefulWidget {
  const ImageQualitySettings({super.key});

  @override
  State<ImageQualitySettings> createState() => _ImageQualitySettingsState();
}

class _ImageQualitySettingsState extends State<ImageQualitySettings> {
  late final SettingsRepositoryImp settingsRepository;
  late bool isHighQuality;
  late final SettingBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<SettingBloc>(context);
    settingsRepository = SettingsRepositoryImp();
    isHighQuality = settingsRepository.getImageQualityState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
        child: RadioGroup<bool>(
          onChanged: (v) {
            setState(() => isHighQuality = v!);
            bloc.add(ChangeImageQualityState(isHighQuality));
          },
          groupValue: isHighQuality,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              radioItem(
                true,
                S.of(context).highQuality,
                S.of(context).betterLook,
              ),
              radioItem(
                false,
                S.of(context).compressed,
                S.of(context).betterForSlowConnectionAndSmallerCache,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget radioItem(bool persist, String languageName, String detail) {
    final TextStyle infoTextStyle = TextStyle(
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontSize: 13,
    );
    return GestureDetector(
      onTap: () {
        setState(() => isHighQuality = persist);
        bloc.add(ChangeImageQualityState(persist));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<bool>(value: persist),
            Expanded(
              child: Wrap(
                spacing: 5,
                children: [
                  Text(languageName),
                  Text(detail, style: infoTextStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
