

class ArtistEntity {
  final String name;
  final int totalLength;
  final int totalAudios;
  final int totalAlbums;

  ArtistEntity({
    required this.name,
    required this.totalLength,
    required this.totalAudios,
    required this.totalAlbums,
  });
}

class AlbumEntity {
  final String name;
  final int totalLength;
  final int totalAudios;

  AlbumEntity({
    required this.name,
    required this.totalLength,
    required this.totalAudios,
  });
}

class GenreEntity {
  final String name;
  final int totalAudios;
  final int totalLength;

  GenreEntity({
    required this.name,
    required this.totalLength,
    required this.totalAudios,
  });
}

class FolderEntity {
  final String name;
  final int totalAudios;
  final int totalLength;

  FolderEntity({
    required this.name,
    required this.totalLength,
    required this.totalAudios,
  });
}
