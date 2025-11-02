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

class PlayAudio extends LocalEvent {
  final int index;

  PlayAudio(this.index);
}

class PlayNextAudio extends LocalEvent {}

class PlayPreviousAudio extends LocalEvent {}

class AutoPlayNext extends LocalEvent {
  final AudioEntity audioEntity;

  AutoPlayNext(this.audioEntity);
}

class TogglePlay extends LocalEvent {}

class DeleteAudio extends LocalEvent {
  AudioEntity audio;

  DeleteAudio(this.audio);
}
