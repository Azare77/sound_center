part of 'local_bloc.dart';

class LocalState {
  LocalStatus status;

  LocalState(this.status);

  LocalState copyWith(LocalStatus status) {
    return LocalState(status);
  }
}
