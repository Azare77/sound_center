import 'package:flutter/material.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/html_parser.dart';

class Description extends StatelessWidget {
  const Description({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            spacing: 15,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: HtmlBuilder(source: description),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).ok),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
