import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late final SettingsRepositoryImp settingsRepository;
  late bool isNotificationPersist;
  late final SettingBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<SettingBloc>(context);
    settingsRepository = SettingsRepositoryImp();
    isNotificationPersist = settingsRepository.getNotificationState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
          child: RadioGroup<bool>(
            onChanged: (v) {
              setState(() => isNotificationPersist = v!);
              bloc.add(ChangeNotificationState(isNotificationPersist));
            },
            groupValue: isNotificationPersist,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                radioItem(true, "Persist"),
                radioItem(false, "Not Persist"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget radioItem(bool persist, String languageName) {
    return GestureDetector(
      onTap: () {
        setState(() => isNotificationPersist = persist);
        bloc.add(ChangeNotificationState(persist));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<bool>(value: persist),
            Expanded(child: Text(languageName)),
          ],
        ),
      ),
    );
  }
}
