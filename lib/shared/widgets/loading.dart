import 'package:flutter/material.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          CircularProgressIndicator(),
          if (label != null) TextView(label!),
        ],
      ),
    );
  }
}
