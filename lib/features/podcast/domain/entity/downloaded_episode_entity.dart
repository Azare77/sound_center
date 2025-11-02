import 'package:drift/drift.dart';
import 'package:podcast_search/podcast_search.dart' as podcast;
import 'package:sound_center/database/drift/database.dart';

class DownloadedEpisodeEntity {
  final String guid;
  final String title;
  final String description;
  final String contentUrl;
  final String? imageUrl;
  final String? author;
  final int length;
  final Duration duration;

  const DownloadedEpisodeEntity({
    required this.guid,
    required this.title,
    required this.description,
    required this.contentUrl,
    required this.length,
    required this.duration,
    this.author,
    this.imageUrl,
  });

  factory DownloadedEpisodeEntity.fromDrift(DownloadTableData data) {
    return DownloadedEpisodeEntity(
      guid: data.guid,
      title: data.title,
      description: data.description,
      duration: Duration(milliseconds: data.duration),
      contentUrl: data.contentUrl,
      length: data.length,
      author: data.author,
      imageUrl: data.imageUrl,
    );
  }

  factory DownloadedEpisodeEntity.fromEpisode(podcast.Episode episode) {
    return DownloadedEpisodeEntity(
      guid: episode.guid,
      title: episode.title,
      contentUrl: episode.contentUrl!,
      duration: episode.duration!,
      description: episode.description,
      length: episode.length,
      imageUrl: episode.imageUrl,
      author: episode.author,
    );
  }

  DownloadTableCompanion toDrift() {
    print(Value(imageUrl));
    return DownloadTableCompanion(
      guid: Value(guid),
      title: Value(title),
      author: Value(author),
      description: Value(description),
      length: Value(length),
      imageUrl: Value(imageUrl),
      contentUrl: Value(contentUrl),
      duration: Value(duration.inMilliseconds),
    );
  }

  podcast.Episode toEpisode() {
    return podcast.Episode(
      guid: guid,
      title: title,
      description: description,
      length: length,
      imageUrl: imageUrl,
      author: author,
      contentUrl: contentUrl,
      duration: duration,
    );
  }
}
