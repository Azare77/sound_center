import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class JustAudioNotificationHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = JustAudioService().getPlayer();

  JustAudioNotificationHandler() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            _player.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
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
  Future<void> play() => LocalPlayerRepositoryImp().togglePlayState();

  @override
  Future<void> pause() => LocalPlayerRepositoryImp().togglePlayState();

  @override
  Future<void> stop() => LocalPlayerRepositoryImp().stop();

  @override
  Future<void> seek(Duration position) =>
      LocalPlayerRepositoryImp().seekNotif(position);

  @override
  Future<void> skipToNext() => LocalPlayerRepositoryImp().next();

  @override
  Future<void> skipToPrevious() => LocalPlayerRepositoryImp().previous();

  void setMediaItemFrom(AudioEntity audio) async {
    final Uri? artUri = await saveCoverToFile(audio.cover, "cover_${audio.id}");

    MediaItem item = MediaItem(
      id: audio.path,
      title: audio.title,
      artist: audio.artist,
      artUri: artUri,
      duration: Duration(milliseconds: audio.duration),
    );

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
          debugPrint("Deleted old cover file: ${file.path}");
        } catch (e) {
          debugPrint(
            "Failed to delete old cover file: ${file.path}, error: $e",
          );
        }
      }
      data ??= await getImageBytesFromAsset('assets/logo.png');
      if (data.isNotEmpty) {
        final file = File('${dir.path}/$fileName.png');
        await file.writeAsBytes(data, flush: true);
        if (await file.exists()) {
          return Uri.file(file.path);
        } else {
          debugPrint("Failed to create cover file: ${file.path}");
          return null;
        }
      }
    } catch (e) {
      debugPrint("Error saving or clearing cover image: $e");
      return null;
    }
    return null;
  }

  Future<Uint8List> getImageBytesFromAsset(String assetPath) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }
}
