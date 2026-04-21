part of 'stream_bloc.dart';

class StreamState {
  StreamStatus status;

  StreamState(this.status);

  StreamState copyWith(StreamStatus status) {
    return StreamState(status);
  }
}
