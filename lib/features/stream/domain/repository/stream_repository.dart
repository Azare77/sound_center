// ignore_for_file: constant_identifier_names

import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';

enum StreamType { staticFile, iceCast }

abstract class StreamRepository {
  StreamType detectStreamType(String url);

  Future<IcecastStream> loadIcecastStream(String url);

  Future<AudioModel> loadAudioInfo(String url);
}
