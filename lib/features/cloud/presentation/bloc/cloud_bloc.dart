import 'package:bloc/bloc.dart';
import 'package:sound_center/database/drift/database.dart';
import 'package:sound_center/features/cloud/data/repository/cloud_repository_imp.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/domain/usecases/get_cloud_usecase.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_status.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

part 'cloud_event.dart';
part 'cloud_state.dart';

class CloudBloc extends Bloc<CloudEvent, CloudState> {
  final AppDatabase _database = AppDatabase();

  CloudBloc() : super(CloudState(LoadingCloud())) {
    final GetCloudUseCase getCloudUseCase = GetCloudUseCase(
      CloudRepositoryImp(),
    );

    // final PodcastPlayerRepositoryImp player = PodcastPlayerRepositoryImp();
    // player.setBloc(this);
    // player.init().then((_) async {
    //   add(CheckPodcastUpdates(null));
    //   Timer.periodic(
    //     Duration(minutes: 30),
    //     (_) => add(CheckPodcastUpdates(null)),
    //   );
    // });

    on<LoadHistory>((event, emit) async {
      emit(
        state.copyWith(CloudHistory(CloudEntity(playlists: [], tracks: []))),
      );
    });

    on<SearchCloud>((event, emit) async {
      if (event.queryText.isEmpty) {
        add(LoadHistory());
      } else {
        emit(state.copyWith(LoadingCloud()));
        CloudEntity result = await getCloudUseCase.search(
          queryText: event.queryText,
          filter: event.filter,
        );
        emit(state.copyWith(SearchResultStatus(searchResult: result)));
      }
    });
    add(LoadHistory());
  }
}
