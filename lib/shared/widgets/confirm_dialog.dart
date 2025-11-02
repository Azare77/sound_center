import 'package:flutter/material.dart';

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
            const Text("Are you sure about that?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Yes"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("No"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
