import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/settings/presentation/bloc/setting_bloc.dart';

class LanguageSettings extends StatelessWidget {
  const LanguageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    SettingBloc bloc = BlocProvider.of<SettingBloc>(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(18.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 5,
            children: [
              TextButton(
                onPressed: () => bloc.add(ChangeLocale(Locale("en"))),
                child: Text("English"),
              ),
              TextButton(
                onPressed: () => bloc.add(ChangeLocale(Locale("fa"))),
                child: Text("فارسی"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
