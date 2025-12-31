import 'package:flutter_test/flutter_test.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

void main() {
  group('AudioEntity JSON and equality', () {
    test('toJson and fromJson roundtrip', () {
      final a = AudioEntity(
        id: 1,
        path: '/tmp/file.mp3',
        title: 'Title',
        duration: 123000,
        album: 'Album',
        genre: 'Genre',
        trackNum: 1,
        isPodcast: false,
        isAlarm: false,
        artist: 'Artist',
        dateAdded: DateTime.utc(2020, 1, 2),
      );

      final json = a.toJson();
      final restored = AudioEntity.fromJson(json);

      expect(restored.id, equals(a.id));
      expect(restored.path, equals(a.path));
      expect(restored.title, equals(a.title));
      expect(restored.duration, equals(a.duration));
    });

    test('equality uses id and path', () {
      final a1 = AudioEntity(
        id: 2,
        path: '/tmp/x.mp3',
        title: 'T',
        duration: 100,
        album: '',
        genre: '',
        trackNum: 0,
        isPodcast: false,
        isAlarm: false,
        artist: '',
        dateAdded: DateTime.now(),
      );
      final a2 = AudioEntity(
        id: 2,
        path: '/tmp/x.mp3',
        title: 'Other',
        duration: 200,
        album: '',
        genre: '',
        trackNum: 0,
        isPodcast: false,
        isAlarm: false,
        artist: '',
        dateAdded: DateTime.now(),
      );

      expect(a1, equals(a2));
    });
  });
}
