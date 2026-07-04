import 'package:drift/drift.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';

class StreamSubEntity {
  final String title;
  final String url;
  final DateTime startAt;
  final bool isOnline;

  StreamSubEntity({
    required this.title,
    required this.url,
    required this.startAt,
    required this.isOnline,
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

  StreamSubscriptionTableCompanion toDrift() {
    return StreamSubscriptionTableCompanion(
      title: Value(title),
      url: Value(url),
      startAt: Value(startAt),
      isOnline: Value(isOnline),
    );
  }
}
