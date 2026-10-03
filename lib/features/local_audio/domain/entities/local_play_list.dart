import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class PlaylistEntity {
  final int id;
  final String title;
  final int order;
  final int itemCount;
  final int totalDuration;
  final List<AudioEntity> audios;

  PlaylistEntity({
    required this.id,
    required this.title,
    required this.order,
    required this.itemCount,
    required this.totalDuration,
    required this.audios,
  });

  factory PlaylistEntity.fromDrift(
    PlaylistTableData item,
    List<AudioEntity> audios,
  ) {
    int duration = 0;
    for (AudioEntity audio in audios) {
      duration += audio.duration;
    }
    return PlaylistEntity(
      id: item.id,
      title: item.title,
      order: item.order,
      itemCount: audios.length,
      totalDuration: duration,
      audios: audios,
    );
  }

  PlaylistTableCompanion toDrift() {
    return PlaylistTableCompanion(order: Value(order), title: Value(title));
  }
}
