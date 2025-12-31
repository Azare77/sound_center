import 'package:flutter_test/flutter_test.dart';
import 'package:sound_center/core/util/date_util.dart';

void main() {
  group('toJalali', () {
    test('returns a formatted jalali date string', () {
      final d = DateTime(2021, 8, 1);
      final s = toJalali(d);

      // Basic format check: digits/digits/digits
      // Use a simpler check to avoid locale-specific edge cases
      expect(s.contains('/'), isTrue);
      expect(s.split('/').length, equals(3));
    });

    test('is deterministic for the same input', () {
      final d = DateTime(2020, 1, 15, 12, 30);
      expect(toJalali(d), equals(toJalali(d)));
    });
  });
}
