import 'package:flutter/material.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  static const _releaseUrl = "https://github.com/Azare77/sound_center/releases";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update_rounded,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: ScrollingText(
                    S.of(context).thereIsANewUpdate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Text(S.of(context).recommendUpdateViaStore),

            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () async {
                  final uri = Uri.parse(_releaseUrl);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(S.of(context).updateNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
