import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_center/shared/theme/themes.dart';

void main() {
  group('ThemeManager custom themes', () {
    test('add and remove custom theme', () {
      final custom = AppThemeData(
        id: 'my_custom',
        brightness: Brightness.light,
        scaffoldBackground: const Color(0xffabcdef),
        thumbColor: const Color(0xff112233),
        appBarBackground: const Color(0xff445566),
        appBarShadowColor: const Color(0xff778899),
        mediaColor: const Color(0xff123456),
        iconColor: Colors.black,
      );

      ThemeManager.addCustomTheme(custom);
      expect(ThemeManager.getCustomTheme('my_custom')?.id, equals('my_custom'));
      expect(ThemeManager.allThemes.any((t) => t.id == 'my_custom'), isTrue);

      ThemeManager.removeCustomTheme('my_custom');
      expect(ThemeManager.getCustomTheme('my_custom'), isNull);
      expect(ThemeManager.allThemes.any((t) => t.id == 'my_custom'), isFalse);
    });

    test('setTheme changes current theme and locale influences font', () {
      ThemeManager.setTheme('dark', const Locale('en'));
      expect(ThemeManager.current.id, equals('dark'));

      ThemeManager.setTheme('light', const Locale('fa'));
      expect(ThemeManager.current.id, equals('light'));
      // ensure font family changes to Vazir for fa
      final data = ThemeManager.getThemeData(ThemeManager.current);
      // bodyText1 was removed in newer Flutter versions; check a modern accessor
      expect(
        data.textTheme.bodyMedium?.fontFamily ?? 'VazirEn',
        equals('Vazir'),
      );
    });
  });
}
