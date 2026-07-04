import 'dart:async';

import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/data/repository/stream_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/domain/entity/stream_sub_entity.dart';
import 'package:sound_center/features/stream/domain/usecases/get_streams_usecase.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_status.dart';

part 'stream_event.dart';
part 'stream_state.dart';

class StreamBloc extends Bloc<StreamEvent, StreamState> {
  final AppDatabase _database = AppDatabase();

  StreamBloc() : super(StreamState(LoadingStream())) {
    final GetStreamsUseCase getStreamUseCase = GetStreamsUseCase(
      StreamRepositoryImp(_database),
    );
    final StreamPlayerRepositoryImp player = StreamPlayerRepositoryImp();
    player.setBloc(this);

    Timer.periodic(Duration(minutes: 10), (_) => add(CheckStreamsStatus(null)));
    on<GetSubscribedStreams>((event, emit) async {
      List<StreamSubEntity> subs = await getStreamUseCase.call();
      emit(state.copyWith(SubscribedStreams(subs)));
    });
    add(GetSubscribedStreams());
    on<CheckStreamsStatus>((event, emit) async {
      List<StreamSubEntity> subs = await getStreamUseCase.checkStreamsStatus();
      event.refreshCompleter?.complete();
      emit(state.copyWith(SubscribedStreams(subs)));
    });
    add(CheckStreamsStatus(null));
    on<SubscribeToStream>((event, emit) async {
      bool success = await getStreamUseCase.subscribe(event.stream);
      if (success) {
        add(GetSubscribedStreams());
      }
    });
    on<UnSubscribeFromStream>((event, emit) async {
      bool success = await getStreamUseCase.unsubscribe(event.stream);
      if (success) {
        add(GetSubscribedStreams());
      }
    });

    on<StreamStaticFile>((event, emit) async {
      final stream = player.getCurrentStream;
      if (player.hasSource() &&
          (stream is AudioModel && stream.path == event.url)) {
        return;
      }
      // icyListener.stop();
      player.setPlayList(event.toAudio());
      await player.play(0, direct: true);
      emit(state.copyWith(state.status));
      AudioModel audio = await getStreamUseCase.getAudio(event.url);
      add(LoadStaticFileInfo(audio));
    });
    on<LoadStaticFileInfo>((event, emit) async {
      final stream = player.getCurrentStream;
      if (stream is AudioModel && stream.path == event.audio.path) {
        player.updateCurrentFileInfo(event.audio);
        emit(state.copyWith(state.status));
      }
    });

    on<LoadStream>((event, emit) async {
      emit(state.copyWith(LoadingStream()));
      final url = event.streamUrl;
      IcecastStream? icecast = await getStreamUseCase.getIcecastStream(url);
      if (icecast != null) {
        emit(state.copyWith(StreamServer(icecast)));
      } else {
        emit(state.copyWith(ErrorLoadStream()));
      }
    });
    on<PlayStream>((event, emit) async {
      // icyListener.stop();
      final stream = player.getCurrentStream;
      if (player.hasSource() &&
          stream is Source &&
          stream.listenUrl == event.stream.listenUrl) {
        return;
      }
      player.setPlayList(event.stream);
      player.play(0, direct: true);
      player.addMetadataListener(() async {
        IcecastStream? icecast = await getStreamUseCase.getIcecastStream(
          event.stream.listenUrl,
        );
        if (icecast == null) return;
        Source? s = icecast.icestats.source.firstWhereOrNull(
          (s) => s.listenUrl == event.stream.listenUrl,
        );
        if (s != null) add(UpdateStreamInfo(icecast, s));
      });
      emit(state.copyWith(state.status));
    });

    on<UpdateStreamInfo>((event, emit) async {
      final stream = player.getCurrentStream;
      if (stream is Source && stream.listenUrl == event.source.listenUrl) {
        player.updateCurrentStreamInfo(event.source);
        emit(state.copyWith(StreamServer(event.stream)));
      }
    });

    on<AutoPlayStream>((event, emit) async {
      emit(state.copyWith(state.status));
    });
    on<TogglePlay>((event, emit) async {
      emit(state.copyWith(state.status));
    });
  }
}
