import 'package:drift/drift.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';

class StreamSubEntity {
  final String title;
  final String url;
  final DateTime startAt;
  final bool isOnline;
  final String? cover;
  final String? uuid;

  StreamSubEntity({
    required this.title,
    required this.url,
    required this.startAt,
    required this.isOnline,
    required this.uuid,
    this.cover,
  });

  factory StreamSubEntity.fromDrift(StreamSubscriptionTableData subscription) {
    return StreamSubEntity(
      title: subscription.title,
      url: subscription.url,
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'startAt': startAt.toIso8601String(),
      'isOnline': isOnline,
      'cover': cover,
      'uuid': uuid,
    };
  }

  factory StreamSubEntity.fromJson(Map<String, dynamic> json) {
    return StreamSubEntity(
      title: json['title'] as String,
      url: json['url'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      isOnline: json['isOnline'] as bool,
      uuid: json['uuid'] as String?,
      cover: json['cover'] as String?,
    );
  }
}
