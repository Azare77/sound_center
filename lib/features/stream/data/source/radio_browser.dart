import 'package:radio_browser_api/radio_browser_api.dart';

class RadioBrowser {
  static final RadioBrowserApi _api = RadioBrowserApi.fromHost(
    "de1.api.radio-browser.info",
  );

  static Future<RadioBrowserListResponse<Station>?> search({
    String? countryCode,
    String? name,
    String? language,
    String? tag,
    required int offset,
  }) async {
    try {
      final stations = await _api.advancedStationSearch(
        countryCode: countryCode,
        language: language,
        name: name,
        tag: tag,
        parameters: InputParameters(offset: offset),
      );
      return stations;
    } catch (_) {
      return null;
    }
  }
}
