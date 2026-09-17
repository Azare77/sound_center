import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/services/just_audio_service.dart' as service;
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_player_rpository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';

class JustAudioNotificationHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = service.JustAudioService().getPlayer();
  final LocalPlayerRepositoryImp _localPlayer = LocalPlayerRepositoryImp();
  final StreamPlayerRepositoryImp _streamPlayer = StreamPlayerRepositoryImp();
  final PodcastPlayerRepositoryImp _podcastPlayer =
      PodcastPlayerRepositoryImp();
  final CloudPlayerRepositoryImp _cloudPlayer = CloudPlayerRepositoryImp();
  service.AudioSource? _source;

  JustAudioNotificationHandler() {
    _player.playbackEventStream.listen((event) {
      List<MediaControl> controls = [];
      List<int> compactIndices = [];

      if (_source == service.AudioSource.local ||
          _source == service.AudioSource.cloud) {
        controls = [
          MediaControl(
            androidIcon: 'drawable/audio_service_skip_previous',
            label: 'Previous',
            action: MediaAction.skipToPrevious,
          ),
          MediaControl(
            androidIcon: _player.playing
                ? 'drawable/audio_service_pause'
                : 'drawable/audio_service_play_arrow',
            label: _player.playing ? 'Pause' : 'Play',
            action: _player.playing ? MediaAction.pause : MediaAction.play,
          ),
          MediaControl(
            androidIcon: 'drawable/audio_service_skip_next',
            label: 'Next',
            action: MediaAction.skipToNext,
          ),
        ];

        compactIndices = const [0, 1, 2];
      }

      if (_source == service.AudioSource.podcast) {
        controls = [
          MediaControl(
            androidIcon: 'drawable/ic_jump_backward',
            label: 'Fast Backward',
            action: MediaAction.rewind,
          ),
          MediaControl(
            androidIcon: 'drawable/audio_service_skip_previous',
            label: 'Previous',
            action: MediaAction.skipToPrevious,
          ),
          MediaControl(
            androidIcon: _player.playing
                ? 'drawable/audio_service_pause'
                : 'drawable/audio_service_play_arrow',
            label: _player.playing ? 'Pause' : 'Play',
            action: _player.playing ? MediaAction.pause : MediaAction.play,
          ),
          MediaControl(
            androidIcon: 'drawable/audio_service_skip_next',
            label: 'Next',
            action: MediaAction.skipToNext,
          ),
          MediaControl(
            androidIcon: 'drawable/ic_jump_forward',
            label: 'Fast Forward',
            action: MediaAction.fastForward,
          ),
        ];

        compactIndices = const [0, 2, 4];
      }

      if (_source == service.AudioSource.stream) {
        controls = [
          MediaControl(
            androidIcon: _player.playing
                ? 'drawable/audio_service_pause'
                : 'drawable/audio_service_play_arrow',
            label: _player.playing ? 'Pause' : 'Play',
            action: _player.playing ? MediaAction.pause : MediaAction.play,
          ),
        ];

        compactIndices = const [0];
      }

      playbackState.add(
        playbackState.value.copyWith(
          controls: controls,
          systemActions: {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
            MediaAction.fastForward,
            MediaAction.rewind,
          },
          androidCompactActionIndices: compactIndices,
          processingState: _mapState(_player.processingState),
          playing: _player.playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
        ),
      );
    });
  }

  AudioProcessingState _mapState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    if (_source == service.AudioSource.local) {
      _localPlayer.resume();
    } else if (_source == service.AudioSource.podcast) {
      _podcastPlayer.resume();
    } else if (_source == service.AudioSource.stream) {
      _streamPlayer.resume();
    } else if (_source == service.AudioSource.cloud) {
      _cloudPlayer.resume();
    }
  }

  @override
  Future<void> pause() async {
    if (_source == service.AudioSource.local) {
      _localPlayer.pause();
    } else if (_source == service.AudioSource.podcast) {
      _podcastPlayer.pause();
    } else if (_source == service.AudioSource.stream) {
      _streamPlayer.pause();
    } else if (_source == service.AudioSource.cloud) {
      _cloudPlayer.pause();
    }
  }

  @override
  Future<void> stop() async {
    if (_source == service.AudioSource.local) {
      _localPlayer.stop();
    } else if (_source == service.AudioSource.podcast) {
      _podcastPlayer.stop();
    }
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_source == service.AudioSource.local) {
      _localPlayer.seek(position);
    } else if (_source == service.AudioSource.podcast) {
      _podcastPlayer.seek(position);
    } else if (_source == service.AudioSource.stream) {
      _streamPlayer.seek(position);
    } else if (_source == service.AudioSource.cloud) {
      _cloudPlayer.seek(position);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_source == service.AudioSource.local) {
      _localPlayer.next(force: true);
    } else if (_source == service.AudioSource.podcast) {
      _podcastPlayer.next();
    } else if (_source == service.AudioSource.cloud) {
      _cloudPlayer.next();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_source == service.AudioSource.local) {
      _localPlayer.previous();
    } else if (_source == service.AudioSource.podcast) {
      _podcastPlayer.previous();
    } else if (_source == service.AudioSource.cloud) {
      _cloudPlayer.previous();
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (_source != service.AudioSource.podcast) return;
    if (name == 'forward30') {
      final dest = _player.position.inMilliseconds + 30000;
      _podcastPlayer.seek(Duration(milliseconds: dest.floor()));
    }
    if (name == 'backward10') {
      final dest = _player.position.inMilliseconds - 10000;
      _podcastPlayer.seek(Duration(milliseconds: dest.floor()));
    }
  }

  void setMediaItemFrom(AudioEntity audio, {Uint8List? cover}) async {
    cover ??= await AudioUtil.getCover(audio.id, coverSize: CoverSize.banner);
    final Uri? artUri = await saveCoverToFile(cover, "cover_${audio.id}");
    _source = service.AudioSource.local;
    MediaItem item = MediaItem(
      id: audio.path,
      title: audio.title,
      artist: audio.artist,
      artUri: artUri,
      duration: Duration(milliseconds: audio.duration),
    );

    mediaItem.add(item);
  }

  void setMediaItemFromEpisode(Episode episode, Uri? cached) async {
    final Uri? artUri = cached ?? Uri.tryParse(episode.imageUrl ?? '');
    MediaItem item = MediaItem(
      id: episode.contentUrl!,
      title: episode.title,
      artist: episode.author,
      artUri: artUri,
      duration: Duration(milliseconds: episode.duration?.inMilliseconds ?? 0),
    );
    _source = service.AudioSource.podcast;
    mediaItem.add(item);
  }

  void setMediaItemFromCloud(CloudTrack track, Uri? cached) async {
    final Uri? artUri =
        cached ?? Uri.tryParse(track.artworkUrl?.toString() ?? '');
    MediaItem item = MediaItem(
      id: track.id.toString(),
      title: track.title,
      artist: track.author,
      artUri: artUri,
      duration: Duration(milliseconds: track.duration.truncate()),
    );
    _source = service.AudioSource.cloud;
    mediaItem.add(item);
  }

  void setMediaItemFromStream({
    required String url,
    required String title,
    String? artist,
    Duration? duration,
    dynamic cover,
    Uri? cached,
  }) async {
    Uri? artUri;
    if (cover is String && cover.isNotEmpty) {
      artUri = cached ?? Uri.tryParse(cover);
    } else {
      artUri = await saveCoverToFile(
        (cover == null || cover.isEmpty) ? null : cover,
        "cover_$title",
      );
    }
    MediaItem item = MediaItem(
      id: url,
      title: title,
      artist: artist,
      artUri: artUri,
      duration: duration,
    );
    _source = service.AudioSource.stream;
    mediaItem.add(item);
  }

  Future<Uri?> saveCoverToFile(Uint8List? data, String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      final coverFiles = dir.listSync().where(
        (file) => file is File && file.path.contains(RegExp(r'cover_.*\.png')),
      );
      for (var file in coverFiles) {
        try {
          await file.delete();
        } catch (_) {}
      }

      data ??= await getImageBytesFromAsset('assets/default-cover.png');
      if (data.isNotEmpty) {
        final file = File('${dir.path}/$fileName.png');
        await file.writeAsBytes(data, flush: true);
        if (await file.exists()) {
          return Uri.file(file.path);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<Uint8List> getImageBytesFromAsset(String assetPath) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }
}
