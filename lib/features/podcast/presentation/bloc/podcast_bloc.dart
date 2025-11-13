import 'package:bloc/bloc.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_repository_imp.dart';
import 'package:sound_center/features/podcast/domain/entity/downloaded_episode_entity.dart';
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
    player.init().then((_) {
      add(GetSubscribedPodcasts());
    });

    Future<void> getSubscribedPodcasts() async {
      add(GetSubscribedPodcasts());
    }

    on<GetSubscribedPodcasts>((event, emit) async {
      List<SubscriptionEntity> subs = await getPodcastUseCase.call();
      emit(state.copyWith(SubscribedPodcasts(subs)));
      subs = await getPodcastUseCase.haveUpdate();
      emit(state.copyWith(SubscribedPodcasts(subs)));
    });
    on<SubscribeToPodcast>((event, emit) async {
      bool success = await getPodcastUseCase.subscribe(event.podcast);
      if (success) {
        await getSubscribedPodcasts();
      }
    });
    on<UpdateSubscribedPodcast>((event, emit) async {
      bool success = await getPodcastUseCase.updateSubscribedPodcast(
        event.podcast,
      );
      if (success) {
        await getSubscribedPodcasts();
      }
    });
    on<UnsubscribeFromPodcast>((event, emit) async {
      bool success = await getPodcastUseCase.unsubscribe(event.feedUrl);
      if (success) {
        await getSubscribedPodcasts();
      }
    });

    on<PlayPodcast>((event, emit) async {
      player.setPlayList(event.episodes);
      if (player.getCurrentEpisode?.guid != event.episodes[event.index].guid ||
          !player.hasSource()) {
        await player.play(event.index, direct: true);
      }
      emit(state.copyWith(state.status));
    });
    on<PlayNextPodcast>((event, emit) async {
      await player.next();
      emit(state.copyWith(state.status));
    });
    on<PlayPreviousPodcast>((event, emit) async {
      await player.previous();
      emit(state.copyWith(state.status));
    });
    on<AutoPlayPodcast>((event, emit) async {
      emit(state.copyWith(state.status));
    });
    //
    on<TogglePlay>((event, emit) async {
      emit(state.copyWith(state.status));
    });

    on<SearchPodcast>((event, emit) async {
      if (event.query.isEmpty) {
        await getSubscribedPodcasts();
      } else {
        emit(state.copyWith(LoadingPodcasts()));
        PodcastEntity podcasts = await getPodcastUseCase.find(event.query);
        PodcastResultStatus status = PodcastResultStatus(
          searchResult: podcasts,
        );
        emit(state.copyWith(status));
      }
    });

    on<GetDownloadedEpisodes>((event, emit) async {
      List<Episode> episodes = await getPodcastUseCase.getDownloadedEpisodes();
      emit(state.copyWith(DownloadedEpisodesStatus(episodes)));
    });

    on<DownloadEpisode>((event, emit) async {
      getPodcastUseCase.downloadEpisode(event.episode);
      add(GetDownloadedEpisodes());
    });
  }
}
