import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/data/source/stream_source.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/repository/stream_repository.dart';
import 'package:sound_center/features/stream/domain/usecases/get_streams_usecase.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_status.dart';

part 'stream_event.dart';
part 'stream_state.dart';

class StreamBloc extends Bloc<StreamEvent, StreamState> {
  StreamBloc() : super(StreamState(LoadingStreamHistory())) {
    final GetStreamsUseCase getStreamUseCase = GetStreamsUseCase(
      StreamRepositoryImp(),
    );
    final StreamPlayerRepositoryImp player = StreamPlayerRepositoryImp();
    player.setBloc(this);
    final IcyListener icyListener = IcyListener();
    on<LoadStream>((event, emit) async {
      emit(state.copyWith(LoadingStreamHistory()));
      final url = event.streamUrl;
      StreamType type = getStreamUseCase.getStreamType(url);
      switch (type) {
        case StreamType.staticFile:
          add(StreamStaticFile(url));
          AudioModel audio = await getStreamUseCase.getAudio(url);
          // emit(state.copyWith(FileStream(audio)));
          add(LoadStaticFileInfo(audio));
          break;
        case StreamType.iceCast:
          IcecastStream icecast = await getStreamUseCase.getIcecastStream(url);
          emit(state.copyWith(StreamServer(icecast)));
      }
    });

    on<StreamStaticFile>((event, emit) async {
      final stream = player.getCurrentStream;
      if (player.hasSource() &&
          (stream is AudioModel && stream.path == event.url)) {
        return;
      }
      icyListener.stop();
      player.setPlayList(event.toAudio());
      await player.play(0, direct: true);
      emit(state.copyWith(state.status));
    });
    on<LoadStaticFileInfo>((event, emit) async {
      final stream = player.getCurrentStream;
      if (stream is AudioModel && stream.path == event.audio.path) {
        player.updateCurrentFileInfo(event.audio);
        emit(state.copyWith(state.status));
      }
    });

    on<PlayStream>((event, emit) async {
      icyListener.stop();
      player.setPlayList(event.stream);
      player.play(0, direct: true);
      icyListener.listenToIcyStream(
        event.stream.listenUrl,
        onMetadata: (title, raw) async {
          IcecastStream icecast = await getStreamUseCase.getIcecastStream(
            event.stream.listenUrl,
          );
          Source? s = icecast.icestats.source.firstWhereOrNull(
            (s) => s.listenUrl == event.stream.listenUrl,
          );
          if (s != null) add(UpdateStreamInfo(icecast, s));
        },
      );
      emit(state.copyWith(state.status));
    });

    on<UpdateStreamInfo>((event, emit) async {
      final stream = player.getCurrentStream;
      if (stream is Source && stream.listenUrl == event.source.listenUrl) {
        player.updateCurrentStreamInfo(event.source);
      }
      emit(state.copyWith(StreamServer(event.stream)));
    });

    on<AutoPlayStream>((event, emit) async {
      emit(state.copyWith(state.status));
    });
    on<TogglePlay>((event, emit) async {
      emit(state.copyWith(state.status));
    });
  }
}
