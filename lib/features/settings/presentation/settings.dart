import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/settings/presentation/pages/language_settings.dart';
import 'package:sound_center/features/settings/presentation/pages/notification_settings.dart';
import 'package:sound_center/features/settings/presentation/pages/provider_settings.dart';
import 'package:sound_center/features/settings/presentation/pages/theme_settings.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:sound_center/shared/widgets/toast_message.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  showDialog(
                    context: context,
                    builder: (_) => NotificationSettings(),
                  );
                },
                child: Text(S.of(context).notification),
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
                        onPressed: () async {
                          final Uri url = Uri.parse(
                            "https://github.com/Azare77/sound_center",
                          );
                          launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                        child: Text(S.of(context).sourceCode),
                      ),
                      TextButton(
                        onPressed: _checkForUpdate,
                        child: Text(S.of(context).checkForUpdates),
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

  Future<void> _checkForUpdate() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.github.com/repos/azare77/sound_center/releases'),
      );

      if (res.statusCode != 200) return;

      final List releases = jsonDecode(res.body);

      final stableReleases = releases.where(
        (r) => r['prerelease'] == false && r['draft'] == false,
      );

      if (stableReleases.isEmpty) return;
      final latestStable = stableReleases.first;

      final isPrerelease = latestStable['prerelease'] ?? false;
      final isDraft = latestStable['draft'] ?? false;
      final textStyle = ThemeManager.getThemeData(
        ThemeManager.current,
      ).textTheme.bodyMedium;
      if (VERSION_NAME != latestStable['tag_name'] &&
          !isPrerelease &&
          !isDraft) {
        ToastMessage.showInfoMessage(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Intl.message(
                  "There is a new update",
                  name: "thereIsANewUpdate",
                ),
                style: textStyle,
              ),
              TextButton(
                onPressed: () async {
                  final Uri url = Uri.parse(
                    "https://github.com/Azare77/sound_center/releases",
                  );
                  launchUrl(url, mode: LaunchMode.externalApplication);
                },
                child: Text(Intl.message("Update Now", name: "updateNow")),
              ),
            ],
          ),
          autoCloseIn: 10,
        );
      } else {
        ToastMessage.showInfoMessage(
          title: Text(
            Intl.message(
              "youAreUsingLatestVersion",
              name: "youAreUsingLatestVersion",
            ),
            style: textStyle,
          ),
          autoCloseIn: 2,
        );
      }
    } catch (_) {}
  }
}
