import 'package:flutter_test/flutter_test.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';

void main() {
  group('AudioUtil time conversions', () {
    test('convertSeekBarTime and convertTime for zero and small values', () {
      expect(AudioUtil.convertSeekBarTime(0), equals('0:00'));
      expect(AudioUtil.convertTime(0), equals(''));

      expect(AudioUtil.convertSeekBarTime(61000), equals('1:01'));
      expect(AudioUtil.convertSeekBarTime(3661000), equals('1:01:01'));
    });
  });
}
