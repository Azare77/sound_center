import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';

sealed class StreamStatus {}

class LoadingStream extends StreamStatus {}

class SubscribedStreams extends StreamStatus {
  List<StreamSubEntity> streams;

  SubscribedStreams(this.streams);
}

class StreamServer extends StreamStatus {
  final IcecastStream stream;

  StreamServer(this.stream);
}

class ErrorLoadStream extends StreamStatus {}

class FileStream extends StreamStatus {
  AudioModel audio;

  FileStream(this.audio);
}
