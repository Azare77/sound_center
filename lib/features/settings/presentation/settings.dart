import 'package:flutter/material.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/settings/presentation/pages/language_settings.dart';
import 'package:sound_center/features/settings/presentation/pages/provider_settings.dart';
import 'package:sound_center/features/settings/presentation/pages/theme_settings.dart';
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
              TextButton(
                onPressed: () {
                  showDialog(context: context, builder: (_) => ThemeSettings());
                },
                child: Text(S.of(context).theme),
              ),
              TextButton(
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationVersion: VERSION_NAME,
                    applicationName: "Sound Center",
                    applicationLegalese:
                        "© 2025 Ali Zare\nReleased under the GNU GPLv3 License.",
                    applicationIcon: Image.asset(
                      'assets/app.png',
                      width: 30,
                      height: 30,
                    ),
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text("Support Project"),
                      ),
                    ],
                  );
                },
                child: Text(S.of(context).moreInfo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
