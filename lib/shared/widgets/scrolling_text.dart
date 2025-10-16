import 'package:flutter/cupertino.dart';
import 'package:text_scroll/text_scroll.dart';

class ScrollingText extends StatelessWidget {
  const ScrollingText(
    this.text, {
    super.key,
    this.mode = TextScrollMode.bouncing,
    this.textAlign,
    this.pauseBetween = 1000,
    this.pauseOnEnd = 500,
    this.delayBefore = 1000,
    this.textDirection,
    this.style,
  });

  final String text;
  final TextScrollMode mode;
  final TextAlign? textAlign;
  final int pauseBetween;
  final int pauseOnEnd;
  final int delayBefore;
  final TextDirection? textDirection;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    late TextDirection finalDirection;
    if (textDirection == null) {
      // اگر شامل کاراکترهای راست به چپ باشد، جهت را تغییر بده
      if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
        finalDirection = TextDirection.rtl;
      } else {
        finalDirection = TextDirection.ltr;
      }
    } else {
      finalDirection = textDirection!;
    }
    return TextScroll(
      text,
      mode: TextScrollMode.endless,
      delayBefore: Duration(milliseconds: delayBefore),
      pauseBetween: Duration(milliseconds: pauseBetween),
      pauseOnBounce: Duration(milliseconds: pauseOnEnd),
      intervalSpaces: 20,
      velocity: Velocity(pixelsPerSecond: Offset(50, 0)),
      textAlign: textAlign,
      selectable: false,
      textDirection: finalDirection,
      style: style,
    );
  }
}
