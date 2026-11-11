class MetadataParser {
  static List<String> extractNames(dynamic items) {
    if (items is! List) {
      return [];
    }

    return items
        .whereType<Map>()
        .map((item) => item['name'])
        .whereType<String>()
        .toSet()
        .toList();
  }

  static Map<String, dynamic> getFirstResult(
    Map<String, dynamic> result,
    String key,
  ) {
    final items = result[key] as List? ?? [];

    if (items.isEmpty) {
      return {};
    }

    return Map<String, dynamic>.from(items.first);
  }

  static int? parseTrackNumber(dynamic number) {
    if (number == null) {
      return null;
    }

    return int.tryParse(number.toString());
  }

  static String? getArtistCredit(List credits) {
    return credits
        .whereType<Map>()
        .map((item) {
          final artist = item['artist'];

          if (artist is Map) {
            return artist['name'];
          }

          return null;
        })
        .whereType<String>()
        .join(', ');
  }
}
