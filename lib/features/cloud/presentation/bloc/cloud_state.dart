part of 'cloud_bloc.dart';

class CloudState {
  CloudStatus status;

  CloudState(this.status);

  CloudState copyWith(CloudStatus status) {
    return CloudState(status);
  }
}
