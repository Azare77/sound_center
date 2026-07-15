// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:radio_browser_api/src/models/list_response.dart';
import 'package:radio_browser_api/src/models/station.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/data/source/radio_browser.dart';
import 'package:sound_center/features/stream/data/source/stream_source.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/domain/repository/stream_repository.dart';

class StreamRepositoryImp implements StreamRepository {
  final AppDatabase database;

  StreamRepositoryImp(this.database);

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

  @override
  Future<IcecastStream?> loadIcecastStream(String url) async {
    if (!url.startsWith(RegExp(r'https?://'))) {
      url = 'http://$url';
    }
    final address = Uri.parse(url);
    final dbUrl = Uri(
      scheme: address.scheme,
      host: address.host,
      port: address.hasPort ? address.port : null,
    );
    final segments = address.pathSegments.where((e) => e.isNotEmpty).toList();

    for (int i = segments.length; i >= 0; i--) {
      final uri = address.replace(
        pathSegments: [...segments.take(i), 'status-json.xsl'],
      );
      final icecastData = await _source.fetchIcecastJson(uri);

      if (icecastData != null) {
        return IcecastStream.fromJson(icecastData, dbUrl.toString());
      }
    }
    return null;
  }

  Future<List<StreamSubscriptionTableData>> _getSubs() async {
    final subs =
        await (database.select(database.streamSubscriptionTable)..orderBy([
              (t) => drift.OrderingTerm(
                expression: t.isOnline,
                mode: drift.OrderingMode.desc,
              ),
              (t) => drift.OrderingTerm(
                expression: t.startAt,
                mode: drift.OrderingMode.desc,
              ),
            ]))
            .get();
    return subs;
  }

  @override
  Future<List<StreamSubEntity>> getSubscribedStreams() async {
    final subs = await _getSubs();
    final models = subs.map((s) => StreamSubEntity.fromDrift(s)).toList();
    return models;
  }

  Future<StreamSubEntity> getSubscribedStream(String url) async {
    Uri address = _parseAddress(url);
    final item = await (database.select(
      database.streamSubscriptionTable,
    )..where((tbl) => tbl.url.equals(address.toString()))).getSingle();
    return StreamSubEntity.fromDrift(item);
  }

  @override
  Future<List<StreamSubEntity>> checkStreamsStatus() async {
    final subs = await _getSubs();
    final streams = await compute(_checkSubscriptionsForUpdates, subs);
    final updates = <Map<String, dynamic>>[];

    for (final sub in subs) {
      final entity = StreamSubEntity.fromDrift(sub);
      final stream = streams[sub.url];
      bool isOnline;
      bool needToUpdate;
      DateTime startAt;

      if (stream == null) {
        isOnline = false;
        startAt = DateTime(1970);
        needToUpdate =
            sub.isOnline != isOnline || !sub.startAt.isAtSameMomentAs(startAt);
      } else {
        isOnline = stream.icestats.source.isNotEmpty;
        startAt = stream.icestats.serverStartIso8601 ?? DateTime(1970);
        needToUpdate =
            !(isOnline && sub.isOnline) ||
            !sub.startAt.isAtSameMomentAs(startAt);
      }

      if (needToUpdate) {
        updates.add({
          "url": entity.url,
          "startAt": startAt,
          "isOnline": isOnline,
        });
      }
    }

    if (updates.isNotEmpty) {
      await database.batch((batch) {
        for (final item in updates) {
          batch.update(
            database.streamSubscriptionTable,
            StreamSubscriptionTableCompanion(
              isOnline: drift.Value(item["isOnline"]),
              startAt: drift.Value(item["startAt"]),
            ),
            where: (t) => t.url.equals(item["url"]),
          );
        }
      });
    }

    return await getSubscribedStreams();
  }

  Future<bool> isSubscribed(String url) async {
    final existing = await (database.select(
      database.streamSubscriptionTable,
    )..where((tbl) => tbl.url.equals(url))).getSingleOrNull();
    if (existing != null) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> subscribeToStream(StreamSubEntity stream) async {
    bool exists = await isSubscribed(stream.url);
    if (exists) return false;
    await database
        .into(database.streamSubscriptionTable)
        .insert(stream.toDrift());
    return true;
  }

  @override
  Future<bool> unsubscribeFromStream(StreamSubEntity stream) async {
    await (database.delete(
      database.streamSubscriptionTable,
    )..where((tbl) => tbl.url.equals(stream.url))).go();
    return true;
  }

  Uri _parseAddress(String url) {
    if (!url.startsWith(RegExp(r'https?://'))) {
      url = 'http://$url';
    }
    final address = Uri.parse(url);
    final dbUrl = Uri(
      scheme: address.scheme,
      host: address.host,
      port: address.hasPort ? address.port : null,
    );
    return dbUrl;
  }

  @override
  Future<RadioBrowserListResponse<Station>?> searchStations({
    String? countryCode,
    String? name,
    String? language,
    String? tag,
    required int offset,
  }) async {
    final response = await RadioBrowser.search(
      offset: offset,
      language: language,
      countryCode: countryCode,
      tag: tag,
      name: name,
    );
    return response;
  }
}

Future<Map<String, IcecastStream>> _checkSubscriptionsForUpdates(
  List<StreamSubscriptionTableData> streams,
) async {
  final cache = <String, IcecastStream>{};

  const maxConcurrent = 6;

  final pool = <Completer<void>>[];

  Future<void> runOne(int id, String url, Completer<void> c) async {
    try {
      final address = Uri.parse(url);
      final uri = Uri(
        scheme: address.scheme,
        host: address.host,
        port: address.hasPort ? address.port : null,
        path: 'status-json.xsl',
      );
      final icecastData = await StreamSource().fetchIcecastJson(uri);
      if (icecastData != null) {
        cache[url] = IcecastStream.fromJson(icecastData, url);
      }
    } catch (_) {}
    c.complete();
  }

  for (final stream in streams) {
    if (pool.length >= maxConcurrent) {
      await Future.any(pool.map((c) => c.future));
      pool.removeWhere((c) => c.isCompleted);
    }

    final completer = Completer<void>();
    pool.add(completer);
    runOne(stream.id, stream.url, completer);
  }
  await Future.wait(pool.map((c) => c.future));

  return cache;
}
