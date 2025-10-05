import 'package:bloc/bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_repository_imp.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/usecases/get_podcasts_usecase.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_status.dart';

part 'podcast_event.dart';
part 'podcast_state.dart';

class PodcastBloc extends Bloc<PodcastEvent, PodcastState> {
  PodcastBloc() : super(PodcastState(LoadingPodcasts())) {
    final GetPodcastsUseCase getPodcastUseCase = GetPodcastsUseCase(
      PodcastRepositoryImp(),
    );

    final PodcastPlayerRepositoryImp player = PodcastPlayerRepositoryImp();
    player.setBloc(this);
    on<GetLocalPodcast>((event, emit) async {
      player.setBloc(this);
    });

    on<PlayPodcast>((event, emit) async {
      player.setPlayList([event.episode]);
      await player.play(0, direct: true);
      emit(state.copyWith(state.status));
    });
    // on<PlayNextAudio>((event, emit) async {
    //   PodcastStatus status = state.status as PodcastStatus;
    //   await player.next();
    //   emit(state.copyWith(status));
    // });
    // on<PlayPreviousAudio>((event, emit) async {
    //   PodcastStatus status = state.status as PodcastStatus;
    //   await player.previous();
    //   emit(state.copyWith(status));
    // });
    on<AutoPlayPodcast>((event, emit) async {
      PodcastResultStatus status = state.status as PodcastResultStatus;
      emit(state.copyWith(status));
    });
    //
    on<TogglePlay>((event, emit) async {
      PodcastResultStatus status = state.status as PodcastResultStatus;
      emit(state.copyWith(status));
    });

    on<SearchPodcast>((event, emit) async {
      emit(state.copyWith(PodcastResultStatus(podcasts: PodcastEntity([]))));
      PodcastEntity podcasts = await getPodcastUseCase.find(event.query);
      PodcastResultStatus status = PodcastResultStatus(podcasts: podcasts);
      emit(state.copyWith(status));
    });
  }
}
