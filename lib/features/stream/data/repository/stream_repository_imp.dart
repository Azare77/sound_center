import 'dart:async';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/data/source/stream_source.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/repository/stream_repository.dart';

class StreamRepositoryImp implements StreamRepository {
  StreamRepositoryImp();

  final StreamSource _source = StreamSource();

  @override
  StreamType detectStreamType(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('icecast') ||
        lower.contains('shoutcast') ||
        lower.endsWith('/stream') ||
        lower.endsWith('/;') ||
        lower.contains('/live') ||
        lower.contains('/radio')) {
      return StreamType.iceCast;
    } else {
      return StreamType.staticFile;
    }
  }

  @override
  Future<IcecastStream> loadIcecastStream(String url) async {
    Map<String, dynamic> icecastData = await _source.fetchIcecastJson(url);
    return IcecastStream.fromJson(icecastData);
  }

  @override
  Future<AudioModel> loadAudioInfo(String url) async {
    AudioMetadata? metadata = await _source.getStaticFileMetadata(url);
    if (metadata != null) {
      return AudioModel(
        id: -1,
        title: metadata.title ?? '',
        path: url,
        duration: metadata.duration?.inMilliseconds ?? 0,
        album: '',
        genre: '',
        trackNum: 0,
        isPodcast: false,
        isAlarm: false,
        artist: metadata.artist ?? '',
        dateAdded: DateTime.now(),
        cover: metadata.pictures.firstOrNull?.bytes,
      );
    }

    return AudioModel(
      id: -1,
      title: "Unknown",
      path: url,
      duration: 0,
      album: '',
      genre: '',
      trackNum: 0,
      isPodcast: false,
      isAlarm: false,
      artist: '',
      dateAdded: DateTime.now(),
    );
  }
}
