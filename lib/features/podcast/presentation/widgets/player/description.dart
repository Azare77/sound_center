import 'package:flutter/material.dart';

class Description extends StatelessWidget {
  const Description({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Text(description, textDirection: TextDirection.rtl),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}
