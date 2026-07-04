import 'package:sound_center/core/usecase/usecase.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/domain/repository/stream_repository.dart';

class GetStreamsUseCase implements UseCase {
  final StreamRepository _streamRepository;

  GetStreamsUseCase(this._streamRepository);

  @override
  Future<List<StreamSubEntity>> call({params}) async {
    return await _streamRepository.getSubscribedStreams();
  }

  Future<List<StreamSubEntity>> checkStreamsStatus() async {
    return await _streamRepository.checkStreamsStatus();
  }

  Future<bool> subscribe(StreamSubEntity stream) async {
    return await _streamRepository.subscribeToStream(stream);
  }

  Future<bool> unsubscribe(StreamSubEntity stream) async {
    return await _streamRepository.unsubscribeFromStream(stream);
  }

  StreamType getStreamType(String url) {
    return _streamRepository.detectStreamType(url);
  }

  Future<AudioModel> getAudio(String url) async {
    return _streamRepository.loadAudioInfo(url);
  }

  Future<IcecastStream?> getIcecastStream(String url) async {
    return _streamRepository.loadIcecastStream(url);
  }
}
