part of 'local_bloc.dart';

sealed class LocalEvent {}

class Search extends LocalEvent {
  final String? query;
  final AudioColumns column;
  final bool desc;

  Search({this.query, AudioColumns? column, bool? desc})
    : column = column ?? LocalOrderStorage.getSavedColumn(),
      desc = desc ?? LocalOrderStorage.getSavedDesc() {
    if (column != null) {
      Storage.instance.prefs.setString('order', column.name);
    }
    if (desc != null) {
      Storage.instance.prefs.setBool('desc', desc);
    }
  }
}

class GetLocalAudios extends LocalEvent {
  final AudioColumns column;
  final bool desc;

  GetLocalAudios({AudioColumns? column, bool? desc})
    : column = column ?? LocalOrderStorage.getSavedColumn(),
      desc = desc ?? LocalOrderStorage.getSavedDesc() {
    if (column != null) {
      Storage.instance.prefs.setString('order', column.name);
    }
    if (desc != null) {
      Storage.instance.prefs.setBool('desc', desc);
    }
  }
}

class GetFavorites extends LocalEvent {}

class AddToFavorites extends LocalEvent {
  final AudioEntity audio;

  AddToFavorites({required this.audio});
}

class RemoveFromFavorites extends LocalEvent {
  final AudioEntity audio;

  RemoveFromFavorites({required this.audio});
}

class GetPlaylists extends LocalEvent {}

class AddToPlaylist extends LocalEvent {
  final int playlistId;
  final List<AudioEntity> audios;

  AddToPlaylist({required this.playlistId, required this.audios});
}

class RemoveFromPlaylist extends LocalEvent {
  final int playlistId;
  final List<AudioEntity> audios;

  RemoveFromPlaylist({required this.playlistId, required this.audios});
}

class CreatePlaylist extends LocalEvent {
  final PlaylistEntity playlist;

  CreatePlaylist({required this.playlist});
}

class RenamePlaylist extends LocalEvent {
  final int playlistId;
  final String newTitle;

  RenamePlaylist({required this.playlistId, required this.newTitle});
}

class DeletePlaylist extends LocalEvent {
  final int playlist;

  DeletePlaylist({required this.playlist});
}

class ChangePlaylistOrder extends LocalEvent {
  final int playlistId;
  final int itemId;
  final int newOrder;

  ChangePlaylistOrder({
    required this.playlistId,
    required this.itemId,
    required this.newOrder,
  });
}

class PlayAudio extends LocalEvent {
  final List<AudioEntity> audios;
  final int index;

  PlayAudio({required this.audios, required this.index});
}

class PlayNextAudio extends LocalEvent {}

class PlayPreviousAudio extends LocalEvent {}

class AutoPlayNext extends LocalEvent {}

class TogglePlay extends LocalEvent {}

class DeleteAudio extends LocalEvent {
  AudioEntity audio;

  DeleteAudio(this.audio);
}
