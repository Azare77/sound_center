import 'dart:convert';

import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';

class PlayerStateStorage {
  static ShuffleMode getShuffleMode() {
    final String? shuffleMode = Storage.instance.prefs.getString('shuffle');
    return ShuffleMode.values.firstWhere(
      (e) => e.name == shuffleMode,
      orElse: () => ShuffleMode.noShuffle,
    );
  }

  static RepeatMode getRepeatMode() {
    final String? repeatMode = Storage.instance.prefs.getString('repeat');
    return RepeatMode.values.firstWhere(
      (e) => e.name == repeatMode,
      orElse: () => RepeatMode.repeatAll,
    );
  }

  static AudioSource? getSource() {
    final String? audioSource = Storage.instance.prefs.getString('source');
    if (audioSource == null) return null;
    return AudioSource.values
        .where((e) => e.name == audioSource)
        .cast<AudioSource?>()
        .firstWhere((_) => true, orElse: () => null);
  }

  static int getLastPosition() {
    int? lastPosition = Storage.instance.prefs.getInt("lastPosition");
    return lastPosition ?? 0;
  }

  static AudioEntity? getLastAudio() {
    final String? jsonString = Storage.instance.prefs.getString('lastAudio');
    if (jsonString == null) return null;
    Map<String, dynamic> lastAudio = jsonDecode(jsonString);
    return AudioEntity.fromJson(lastAudio);
  }

  static Episode? getLastEpisode() {
    List<String>? episodeInfo;
    episodeInfo = Storage.instance.prefs.getStringList("lastPodcast");
    if (episodeInfo == null) return null;
    return Episode(
      guid: episodeInfo[0],
      title: episodeInfo[1],
      description: episodeInfo[2],
      length: int.tryParse(episodeInfo[3]) ?? 0,
      duration: Duration(milliseconds: int.tryParse(episodeInfo[4]) ?? 0),
      imageUrl: episodeInfo[5],
      author: episodeInfo[6],
      contentUrl: episodeInfo[7],
    );
  }

  static Future<void> saveShuffleMode(ShuffleMode mode) async {
    await Storage.instance.prefs.setString("shuffle", mode.name);
  }

  static Future<void> saveRepeatMode(RepeatMode mode) async {
    await Storage.instance.prefs.setString("repeat", mode.name);
  }

  static Future<void> saveLastPosition(int lastPosition) async {
    await Storage.instance.prefs.setInt("lastPosition", lastPosition);
  }

  static Future<void> saveLastAudio(AudioEntity audio) async {
    String jsonString = jsonEncode(audio.toJson());
    await Storage.instance.prefs.setString("lastAudio", jsonString);
  }

  static Future<void> saveLastEpisode(Episode episode) async {
    List<String> episodeInfo = [
      episode.guid,
      episode.title,
      episode.description,
      episode.length.toString(),
      (episode.duration?.inMilliseconds ?? 0).toString(),
      episode.imageUrl ?? "",
      episode.author ?? "",
      episode.contentUrl!,
    ];
    await Storage.instance.prefs.setStringList("lastPodcast", episodeInfo);
  }

  static Future<void> saveSource(AudioSource source) async {
    await Storage.instance.prefs.setString("source", source.name);
  }
}
