import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/domain/usecases/get_audios_usecase.dart';

class _MockRepo extends Mock implements AudioRepository {}

void main() {
  late _MockRepo repo;
  late GetAudioUseCase usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = GetAudioUseCase(repo);
  });

  test('call returns repository result', () async {
    final audio = AudioModel(
      id: 1,
      path: '/f.mp3',
      title: 't',
      duration: 1000,
      album: 'a',
      genre: 'g',
      trackNum: 1,
      isPodcast: false,
      isAlarm: false,
      artist: 'ar',
      dateAdded: DateTime.utc(2020, 1, 1),
    );

    when(() => repo.fetchLocalAudios(
          like: any(named: 'like'),
          orderBy: AudioColumns.id,
          desc: false,
        )).thenAnswer((_) async => [audio]);

    final res = await usecase.call(orderBy: AudioColumns.id, desc: false);
    expect(res.length, equals(1));
    expect(res.first.id, equals(audio.id));
  });

  test('search forwards like parameter to repository', () async {
    final audio = AudioModel(
      id: 2,
      path: '/g.mp3',
      title: 't2',
      duration: 2000,
      album: 'a',
      genre: 'g',
      trackNum: 2,
      isPodcast: false,
      isAlarm: false,
      artist: 'ar',
      dateAdded: DateTime.utc(2021, 1, 1),
    );

    when(() => repo.fetchLocalAudios(
          like: any(named: 'like'),
          orderBy: AudioColumns.id,
          desc: any(named: 'desc'),
        )).thenAnswer((_) async => [audio]);

    final res = await usecase.search(params: 'needle');
    expect(res.length, equals(1));
    expect(res.first.id, equals(2));
    verify(() => repo.fetchLocalAudios(like: any(named: 'like'), orderBy: AudioColumns.id, desc: any(named: 'desc'))).called(1);
  });
}
