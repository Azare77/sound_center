// ignore_for_file: constant_identifier_names

import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';

enum StreamType { staticFile, iceCast }

abstract class StreamRepository {
  StreamType detectStreamType(String url);

  Future<RadioBrowserListResponse<Station>> searchStations({
    String? country,
    String? name,
    String? language,
    required int offset,
  });

  Future<IcecastStream?> loadIcecastStream(String url);

  Future<AudioModel> loadAudioInfo(String url);

  Future<List<StreamSubEntity>> getSubscribedStreams();

  Future<List<StreamSubEntity>> checkStreamsStatus();

  Future<bool> subscribeToStream(StreamSubEntity stream);

  Future<bool> unsubscribeFromStream(StreamSubEntity stream);
}
