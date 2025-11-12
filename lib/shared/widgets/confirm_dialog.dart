import 'package:flutter/material.dart';
import 'package:sound_center/generated/l10n.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 30,
          children: [
            Text(S.of(context).areYouSureAboutThat),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(S.of(context).yes),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(S.of(context).no),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
