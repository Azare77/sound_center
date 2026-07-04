import 'package:flutter/material.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class StreamNameDialog extends StatefulWidget {
  const StreamNameDialog({super.key});

  @override
  State<StreamNameDialog> createState() => _StreamNameDialogState();
}

class _StreamNameDialogState extends State<StreamNameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onSubmit(String url) {
    url = url.trim();
    Navigator.pop(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldBox(
              controller: _controller,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              labelText: "Stream Name",
              onSubmitted: onSubmit,
            ),
            TextButton(
              onPressed: () => onSubmit(_controller.text),
              child: Text(S.of(context).submit),
            ),
          ],
        ),
      ),
    );
  }
}
