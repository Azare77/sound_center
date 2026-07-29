// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/settings/presentation/pages/update_dialog.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:sound_center/shared/widgets/toast_message.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDialogBody extends StatelessWidget {
  const AboutDialogBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
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
          onPressed: () => _checkForUpdate(context),
          child: Text(S.of(context).checkForUpdates),
        ),
      ],
    );
  }

  Future<void> _checkForUpdate(BuildContext context) async {
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
        showDialog(context: context, builder: (_) => UpdateDialog());
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
