import 'dart:convert';
import 'dart:math';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:radio_browser_api/radio_browser_api.dart';

class RadioBrowser {
  RadioBrowserApi? _api;
  static final RadioBrowser _instance = RadioBrowser._internal();
  static final Map<String, Station> _stationCache = {};
  static final Map<String, DateTime> _cachedTime = {};

  factory RadioBrowser() {
    return _instance;
  }

  RadioBrowser._internal();

  Future<void>? _initializing;

  RadioBrowser.initialize(String? host) {
    if (host != null) {
      _api = RadioBrowserApi.fromHost(host);
    } else {
      _initializing = _init();
    }
  }

  Future<void> ensureInitialized() async {
    if (_api != null) return;

    if (_initializing != null) {
      await _initializing;
      return;
    }

    _initializing = _init();
    await _initializing;
  }

  Future<RadioBrowserApi> _init() async {
    final servers = await _getServers();

    if (servers.isEmpty) {
      throw Exception('No RadioBrowser servers available');
    }

    servers.shuffle(Random());

    for (final host in servers) {
      try {
        final api = RadioBrowserApi.fromHost(host);

        await api.getStationsByName(name: 'test');

        _api = api;
        return api;
      } catch (_) {
        continue;
      }
    }

    throw Exception('Could not connect to RadioBrowser');
  }

  Future<List<String>> _getServers() async {
    final response = await http.get(
      Uri.parse('https://all.api.radio-browser.info/json/servers'),
      headers: {'User-Agent': 'SoundCenter/1.0'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get servers');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((e) => e['name'] as String)
        .map(
          (host) =>
              host.replaceFirst('https://', '').replaceFirst('http://', ''),
        )
        .toList();
  }

  Future<RadioBrowserListResponse<Station>?> search({
    String? countryCode,
    String? name,
    String? language,
    String? tag,
    required int offset,
  }) async {
    try {
      await ensureInitialized();

      final res = await _api!.advancedStationSearch(
        countryCode: countryCode,
        language: language,
        name: name,
        tag: tag,
        parameters: InputParameters(offset: offset, limit: 200),
      );
      for (var i in res.items) {
        _stationCache[i.stationUUID] = i;
        _cachedTime[i.stationUUID] = DateTime.now();
      }
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<List<Country>?> getCountries() async {
    try {
      await ensureInitialized();

      final countries = await _api!.getCountries();
      return countries.items;
    } catch (_) {
      return null;
    }
  }

  Future<List<Language>?> getLanguages() async {
    try {
      await ensureInitialized();

      final languages = await _api!.getLanguages();
      return languages.items;
    } catch (_) {
      return null;
    }
  }

  Future<List<Tag>?> getTags() async {
    try {
      await ensureInitialized();

      final tags = await _api!.getTags();
      return tags.items;
    } catch (_) {
      return null;
    }
  }

  Future<Station?> _getStation(String uuid) async {
    try {
      await ensureInitialized();

      final stations = await _api!.getStationsByUUID(uuids: [uuid]);
      return stations.items.firstOrNull;
    } catch (_) {
      return null;
    }
  }

  Future<Station?> loadStationInfo(
    String uuid, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    final cached = _stationCache[uuid];
    if (cached != null) {
      final cachedTime = _cachedTime[uuid]!;
      if (DateTime.now().difference(cachedTime) < ttl) {
        return cached;
      }
    }

    final station = await _getStation(uuid);
    if (station == null) return null;
    _stationCache[uuid] = station;
    _cachedTime[uuid] = DateTime.now();
    return station;
  }
}
