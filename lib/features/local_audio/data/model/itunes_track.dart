class ItunesTrack {
  final String? trackName;
  final String? artistName;
  final String? collectionName;
  final String? albumArtistName;
  final String? artworkUrl;
  final String? artworkUrlLarge;
  final String? trackViewUrl;
  final String? collectionViewUrl;
  final String? primaryGenreName;
  final String? releaseDate;
  final String? country;
  final String? currency;
  final String? kind;
  final int? trackId;
  final int? collectionId;
  final int? trackNumber;
  final int? trackCount;
  final int? discNumber;
  final int? discCount;
  final int? trackTimeMillis;
  final int? releaseYear;
  final double? trackPrice;
  final double? collectionPrice;

  const ItunesTrack({
    this.trackName,
    this.artistName,
    this.collectionName,
    this.albumArtistName,
    this.artworkUrl,
    this.artworkUrlLarge,
    this.trackViewUrl,
    this.collectionViewUrl,
    this.primaryGenreName,
    this.releaseDate,
    this.country,
    this.currency,
    this.kind,
    this.trackId,
    this.collectionId,
    this.trackNumber,
    this.trackCount,
    this.discNumber,
    this.discCount,
    this.trackTimeMillis,
    this.releaseYear,
    this.trackPrice,
    this.collectionPrice,
  });

  factory ItunesTrack.fromJson(Map<String, dynamic> json) {
    final artwork = json['artworkUrl100'] as String?;

    return ItunesTrack(
      trackName: json['trackName'],
      artistName: json['artistName'],
      collectionName: json['collectionName'],
      albumArtistName: json['collectionArtistName'],
      artworkUrl: artwork,
      artworkUrlLarge: artwork?.replaceAll('100x100bb', '600x600bb'),
      trackViewUrl: json['trackViewUrl'],
      collectionViewUrl: json['collectionViewUrl'],
      primaryGenreName: json['primaryGenreName'],
      releaseDate: json['releaseDate'],
      country: json['country'],
      currency: json['currency'],
      kind: json['kind'],
      trackId: json['trackId'],
      collectionId: json['collectionId'],
      trackNumber: json['trackNumber'],
      trackCount: json['trackCount'],
      discNumber: json['discNumber'],
      discCount: json['discCount'],
      trackTimeMillis: json['trackTimeMillis'],
      releaseYear: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'])?.year
          : null,
      trackPrice: (json['trackPrice'] as num?)?.toDouble(),
      collectionPrice: (json['collectionPrice'] as num?)?.toDouble(),
    );
  }
}
