import 'package:radio_browser_api/radio_browser_api.dart';

class IcecastStream {
  final IceStats icestats;

  IcecastStream({required this.icestats});

  factory IcecastStream.fromJson(Map<String, dynamic> json, String server) {
    return IcecastStream(icestats: IceStats.fromJson(json['icestats'], server));
  }

  Map<String, dynamic> toJson() {
    return {'icestats': icestats.toJson()};
  }
}

class IceStats {
  String? title;
  final String? url;
  final String? admin;
  final String? host;
  final String? location;
  final String? serverId;
  final String? serverStart;
  final DateTime? serverStartIso8601;
  List<Source> source;

  IceStats({
    this.title,
    this.url,
    this.admin,
    this.host,
    this.location,
    this.serverId,
    this.serverStart,
    this.serverStartIso8601,
    required this.source,
  });

  factory IceStats.fromJson(Map<String, dynamic> json, String server) {
    final rawSource = json['source'];
    late final DateTime? serverStartIso8601;
    try {
      serverStartIso8601 = DateTime.parse(json['server_start_iso8601']);
    } catch (_) {
      serverStartIso8601 = null;
    }

    List<Source> sources;

    if (rawSource is List) {
      sources = rawSource.map((e) => Source.fromJson(e)).toList();
    } else if (rawSource is Map<String, dynamic>) {
      sources = [Source.fromJson(rawSource)];
    } else {
      sources = [];
    }

    return IceStats(
      title: json['title'],
      url: server,
      admin: json['admin'],
      host: json['host'],
      location: json['location'],
      serverId: json['server_id'],
      serverStart: json['server_start'],
      serverStartIso8601: serverStartIso8601,
      source: sources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'admin': admin,
      'host': host,
      'location': location,
      'server_id': serverId,
      'server_start': serverStart,
      'server_start_iso8601': serverStartIso8601,
      'source': source.map((e) => e.toJson()).toList(),
    };
  }
}

class Source {
  final String? audioInfo;
  final int? bitrate;
  final String? genre;
  final int listenerPeak;
  final int listeners;
  final String listenUrl;
  final String? serverDescription;
  final String? serverName;
  final String? serverType;
  final String? serverUrl;
  final String? streamStart;
  final DateTime? streamStartIso8601;
  final String? title;
  final String? cover;
  final String? uuid;

  Source({
    required this.listenUrl,
    this.audioInfo,
    this.bitrate,
    this.genre,
    this.listenerPeak = 0,
    this.listeners = 0,
    this.serverDescription,
    this.serverName,
    this.serverType,
    this.serverUrl,
    this.streamStart,
    this.streamStartIso8601,
    this.title,
    this.cover,
    this.uuid,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    late final DateTime? streamStartIso8601;
    try {
      streamStartIso8601 = DateTime.parse(json['stream_start_iso8601']);
    } catch (_) {
      streamStartIso8601 = null;
    }
    return Source(
      audioInfo: json['audio_info'],
      bitrate: json['bitrate'],
      genre: json['genre'],
      listenerPeak: json['listener_peak'],
      listeners: json['listeners'],
      listenUrl: json['listenurl'],
      serverDescription: json['server_description'],
      serverName: json['server_name'],
      serverType: json['server_type'],
      serverUrl: json['server_url'],
      streamStart: json['stream_start'],
      streamStartIso8601: streamStartIso8601,
      title: json['title'],
      uuid: json['uuid'],
    );
  }

  factory Source.fromStation(Station station) {
    return Source(
      listenUrl: station.urlResolved!,
      title: station.name,
      cover: station.favicon,
      uuid: station.stationUUID,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audio_info': audioInfo,
      'bitrate': bitrate,
      'genre': genre,
      'listener_peak': listenerPeak,
      'listeners': listeners,
      'listenurl': listenUrl,
      'server_description': serverDescription,
      'server_name': serverName,
      'server_type': serverType,
      'server_url': serverUrl,
      'stream_start': streamStart,
      'stream_start_iso8601': streamStartIso8601,
      'title': title,
      'uuid': uuid,
    };
  }
}
