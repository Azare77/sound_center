import 'package:drift/drift.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';

class StreamSubEntity {
  final String title;
  final String url;
  final String audioUrl;
  final DateTime startAt;
  final bool isOnline;
  final String? cover;
  final String? uuid;

  StreamSubEntity({
    required this.title,
    required this.url,
    required this.startAt,
    required this.audioUrl,
    required this.isOnline,
    required this.uuid,
    this.cover,
  });

  factory StreamSubEntity.fromDrift(StreamSubscriptionTableData subscription) {
    return StreamSubEntity(
      title: subscription.title,
      url: subscription.url,
      audioUrl: subscription.url,
      cover: subscription.cover,
      startAt: subscription.startAt,
      isOnline: subscription.isOnline,
      uuid: subscription.uuid,
    );
  }

  factory StreamSubEntity.fromIcecast(IceStats server) {
    return StreamSubEntity(
      title: server.title!,
      url: server.url!,
      audioUrl: server.title!,
      startAt: server.serverStartIso8601 ?? DateTime(1970),
      isOnline: server.source.isNotEmpty,
      uuid: null,
    );
  }

  factory StreamSubEntity.fromStation(Station server) {
    return StreamSubEntity(
      title: server.name,
      url: server.url,
      startAt: server.lastCheckOkTime ?? DateTime(1970),
      isOnline: false,
      cover: server.favicon,
      audioUrl: server.urlResolved!,
      uuid: server.stationUUID,
    );
  }

  StreamSubscriptionTableCompanion toDrift() {
    return StreamSubscriptionTableCompanion(
      title: Value(title),
      url: Value(url),
      startAt: Value(startAt),
      isOnline: Value(isOnline),
      cover: Value(cover),
      uuid: Value(uuid),
    );
  }
}
