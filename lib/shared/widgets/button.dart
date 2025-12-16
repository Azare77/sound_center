import 'package:flutter/material.dart';

import 'loading.dart';
import 'text_view.dart';

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.width,
    this.style,
  });

  final String buttonText;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final Function() onPressed;
  final ButtonStyle? style;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool sending = false;

  @override
  Widget build(BuildContext context) {
    ButtonStyle correctStyle =
        widget.style ??
        ButtonStyle(
          backgroundColor: WidgetStateProperty.all(widget.backgroundColor),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: widget.width,
        child: ElevatedButton(
          onPressed: () async {
            setState(() {
              sending = true;
            });
            await widget.onPressed();
            setState(() {
              sending = false;
            });
          },
          style: correctStyle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: sending
                ? const Loading()
                : TextView(
                    widget.buttonText,
                    style: TextStyle(color: widget.textColor),
                  ),
          ),
        ),
      ),
    );
  }
}
