import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  const TextView(
    this.data, {
    super.key,
    this.maxLines,
    this.textAlign,
    this.style,
    this.overflow,
    this.direction,
  });

  final String data;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextStyle? style;
  final TextOverflow? overflow;
  final TextDirection? direction;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      textDirection: direction,
    );
  }
}
