import 'package:flutter/material.dart';
import 'package:sound_center/features/settings/presentation/pages/language_settings.dart';
import 'package:sound_center/features/settings/presentation/pages/provider_settings.dart';
import 'package:sound_center/generated/l10n.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 5,
            children: [
              Text(S.of(context).settings),
              Divider(),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProviderSettings(),
                  );
                },
                child: Text(S.of(context).podcastApi),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => LanguageSettings(),
                  );
                },
                child: Text(S.of(context).language),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
