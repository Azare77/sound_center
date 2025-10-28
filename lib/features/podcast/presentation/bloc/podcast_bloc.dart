import 'package:bloc/bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_repository_imp.dart';
import 'package:sound_center/features/podcast/domain/entity/podcast_entity.dart';
import 'package:sound_center/features/podcast/domain/entity/subscription_entity.dart';
import 'package:sound_center/features/podcast/domain/usecases/get_podcasts_usecase.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_status.dart';

part 'podcast_event.dart';
part 'podcast_state.dart';

class PodcastBloc extends Bloc<PodcastEvent, PodcastState> {
  final AppDatabase _database = AppDatabase();

  PodcastBloc() : super(PodcastState(LoadingPodcasts())) {
    final GetPodcastsUseCase getPodcastUseCase = GetPodcastsUseCase(
      PodcastRepositoryImp(_database),
    );

    final PodcastPlayerRepositoryImp player = PodcastPlayerRepositoryImp();
    player.setBloc(this);
    on<GetLocalPodcast>((event, emit) async {
      List<SubscriptionEntity> subs = await getPodcastUseCase.call();
      emit(state.copyWith(SubscribedPodcasts(subs)));
    });
    on<SubscribeToPodcast>((event, emit) async {
      bool success = await getPodcastUseCase.subscribe(event.podcast);
      if (success) {
        add(GetLocalPodcast());
      }
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
      emit(state.copyWith(state.status));
    });
    //
    on<TogglePlay>((event, emit) async {
      emit(state.copyWith(state.status));
    });

    on<SearchPodcast>((event, emit) async {
      if (event.query.isEmpty) {
        add(GetLocalPodcast());
      } else {
        emit(state.copyWith(LoadingPodcasts()));
        PodcastEntity podcasts = await getPodcastUseCase.find(event.query);
        PodcastResultStatus status = PodcastResultStatus(podcasts: podcasts);
        emit(state.copyWith(status));
      }
    });
  }
}
