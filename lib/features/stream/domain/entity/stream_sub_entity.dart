import 'package:drift/drift.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';

class StreamSubEntity {
  final String title;
  final String url;
  final DateTime startAt;
  final bool isOnline;
  final String? logo;

  StreamSubEntity({
    required this.title,
    required this.url,
    required this.startAt,
    required this.isOnline,
    this.logo,
  });

  factory StreamSubEntity.fromDrift(StreamSubscriptionTableData subscription) {
    return StreamSubEntity(
      title: subscription.title,
      url: subscription.url,
      startAt: subscription.startAt,
      isOnline: subscription.isOnline,
    );
  }

  factory StreamSubEntity.fromIcecast(IceStats server) {
    return StreamSubEntity(
      title: server.title!,
      url: server.url!,
      startAt: server.serverStartIso8601 ?? DateTime(1970),
      isOnline: server.source.isNotEmpty,
    );
  }

  factory StreamSubEntity.fromStation(Station server) {
    return StreamSubEntity(
      title: "${server.name}-${server.state}",
      url: server.url,
      startAt: server.lastCheckOkTime ?? DateTime(1970),
      isOnline: false,
      logo: server.favicon,
    );
  }

  StreamSubscriptionTableCompanion toDrift() {
    return StreamSubscriptionTableCompanion(
      title: Value(title),
      url: Value(url),
      startAt: Value(startAt),
      isOnline: Value(isOnline),
    );
  }
}
