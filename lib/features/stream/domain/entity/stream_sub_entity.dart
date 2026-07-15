import 'dart:convert';

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
  final Station? fullData;

  StreamSubEntity({
    required this.title,
    required this.url,
    required this.startAt,
    required this.audioUrl,
    required this.isOnline,
    required this.fullData,
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
      fullData: subscription.fullData != null
          ? Station.fromJson(jsonDecode(subscription.fullData!))
          : null,
    );
  }

  factory StreamSubEntity.fromIcecast(IceStats server) {
    return StreamSubEntity(
      title: server.title!,
      url: server.url!,
      audioUrl: server.title!,
      startAt: server.serverStartIso8601 ?? DateTime(1970),
      isOnline: server.source.isNotEmpty,
      fullData: null,
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
      fullData: server,
    );
  }

  StreamSubscriptionTableCompanion toDrift() {
    return StreamSubscriptionTableCompanion(
      title: Value(title),
      url: Value(url),
      startAt: Value(startAt),
      isOnline: Value(isOnline),
      cover: Value(cover),
      fullData: Value(fullData != null ? jsonEncode(fullData!.toJson()) : null),
    );
  }
}
