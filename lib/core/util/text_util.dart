import 'dart:ui';

import 'package:collection/collection.dart';

class TextUtil {
  static TextDirection getTextDirection(String text) {
    int rtl = 0;
    int ltr = 0;

    for (final rune in text.runes) {
      // Arabic, Persian, Hebrew...
      if ((rune >= 0x0590 && rune <= 0x08FF) ||
          (rune >= 0xFB1D && rune <= 0xFDFF) ||
          (rune >= 0xFE70 && rune <= 0xFEFF)) {
        rtl++;
      }
      // Latin letters
      else if ((rune >= 0x0041 && rune <= 0x005A) ||
          (rune >= 0x0061 && rune <= 0x007A)) {
        ltr++;
      }
    }

    return rtl > ltr ? TextDirection.rtl : TextDirection.ltr;
  }
}
