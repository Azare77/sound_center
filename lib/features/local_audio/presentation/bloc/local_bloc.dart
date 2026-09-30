import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:sound_center/database/shared_preferences/loca_order_storage.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/local_audio/data/repositories/linux_audio_repository.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_audio_repository.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/domain/usecases/get_audios_usecase.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';

part 'local_event.dart';
part 'local_state.dart';

class LocalBloc extends Bloc<LocalEvent, LocalState> {
  LocalBloc() : super(LocalState(LoadingLocalAudios())) {
    late final GetAudioUseCase getAudioUseCase;
    if (Platform.isLinux) {
      getAudioUseCase = GetAudioUseCase(LocalAudioRepositoryLinux());
    } else {
      getAudioUseCase = GetAudioUseCase(LocalAudioRepository());
    }
    final LocalPlayerRepositoryImp player = LocalPlayerRepositoryImp();
    player.setBloc(this);
    getAudioUseCase
        .call(
          orderBy: LocalOrderStorage.getSavedColumn(),
          desc: LocalOrderStorage.getSavedDesc(),
        )
        .then((audios) {
          player.setPlayList(audios);
          add(GetLocalAudios());
          add(GetFavorites());
          add(GetPlaylists());
          player.init();
        });
    on<GetLocalAudios>((event, emit) async {
      List<AudioEntity> audios = await getAudioUseCase.call(
        orderBy: event.column,
        desc: event.desc,
      );
      emit(state.copyWith(LocalAudioStatus(audios: audios)));
    });
    on<PlayAudio>((event, emit) async {
      player.setPlayList(event.audios);
      if (player.getCurrentAudio?.id != event.audios[event.index].id ||
          !player.hasSource()) {
        await player.play(event.index, direct: true);
      } else if (!player.isPlaying()) {
        player.togglePlayState();
      }
    });

    on<PlayNextAudio>((event, emit) async {
      await player.next(force: true);
      emit(state.copyWith(state.status));
    });

    on<PlayPreviousAudio>((event, emit) async {
      await player.previous();
      emit(state.copyWith(state.status));
    });

    on<AutoPlayNext>((event, emit) async {
      LocalStatus status = state.status;
      emit(state.copyWith(status));
    });

    on<TogglePlay>((event, emit) async {
      LocalAudioStatus status = state.status as LocalAudioStatus;
      final newStatus = LocalAudioStatus(audios: status.audios);
      emit(state.copyWith(newStatus));
    });

    on<DeleteAudio>((event, emit) async {
      await player.removeAudio(event.audio);
      await getAudioUseCase.deleteAudio(event.audio);
      add(GetLocalAudios());
    });

    on<Search>((event, emit) async {
      // List<AudioEntity> audios = await getAudioUseCase.search(
      //   params: event.query,
      //   orderBy: event.column,
      //   desc: event.desc,
      // );
      // LocalAudioStatus status = state.status as LocalAudioStatus;
      // status.audios = audios;
      // emit(state.copyWith(status));
    });

    on<GetPlaylists>((event, emit) async {
      final List<PlayListEntity> playlists = await getAudioUseCase
          .getPlaylists();
      emit(state.copyWith(LocalPlayListsStatus(playlists: playlists)));
    });
    on<GetFavorites>((event, emit) async {
      final List<AudioEntity> favorites = await getAudioUseCase.getFavorites();
      emit(state.copyWith(LocalFavoriteStatus(audios: favorites)));
    });
    on<AddToFavorites>((event, emit) async {
      final bool res = await getAudioUseCase.fave(event.audio.id);
      if (res) add(GetFavorites());
    });
    on<RemoveFromFavorites>((event, emit) async {
      final bool res = await getAudioUseCase.unfave(event.audio.id);
      if (res) add(GetFavorites());
    });
  }
}
