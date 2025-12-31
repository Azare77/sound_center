import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_center/shared/theme/themes.dart';

void main() {
  group('AppThemeData serialization', () {
    test('toJsonForStorage and fromJsonForStorage roundtrip', () {
      final t = AppThemeData(
        id: 'custom',
        brightness: Brightness.light,
        scaffoldBackground: const Color(0xff123456),
        thumbColor: const Color(0xff112233),
        appBarBackground: const Color(0xff445566),
        appBarShadowColor: const Color(0xff778899),
        mediaColor: const Color(0xffabcdef),
        iconColor: Colors.black,
      );

      final json = t.toJsonForStorage();
      final restored = AppThemeData.fromJsonForStorage(json);

      expect(restored.id, equals(t.id));
      expect(restored.brightness, equals(t.brightness));
      expect(restored.scaffoldBackground, equals(t.scaffoldBackground));
      expect(restored.thumbColor, equals(t.thumbColor));
      expect(restored.appBarBackground, equals(t.appBarBackground));
      expect(restored.appBarShadowColor, equals(t.appBarShadowColor));
      expect(restored.mediaColor, equals(t.mediaColor));
      expect(restored.iconColor, equals(t.iconColor));
    });
  });
}
