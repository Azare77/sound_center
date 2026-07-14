import 'package:radio_browser_api/radio_browser_api.dart';

class RadioBrowser {
  static final RadioBrowserApi _api = RadioBrowserApi.fromHost(
    "de1.api.radio-browser.info",
  );

  static Future<RadioBrowserListResponse<Station>> search({
    String? country,
    String? name,
    String? language,
    required int offset,
  }) async {
    final stations = await _api.advancedStationSearch(
      country: country,
      language: language,
      name: name,
      parameters: InputParameters(offset: offset),
    );
    return stations;
  }
}
