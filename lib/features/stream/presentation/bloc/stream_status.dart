import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';

sealed class StreamStatus {}

class LoadingStreamHistory extends StreamStatus {}

class StreamServer extends StreamStatus {
  final IcecastStream stream;

  StreamServer(this.stream);
}

class FileStream extends StreamStatus {
  AudioModel audio;

  FileStream(this.audio);
}
