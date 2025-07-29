import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core/util/permission/permission_handler.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_audio_repository.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_list_template.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/current_audio.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class LocalAudios extends StatefulWidget {
  const LocalAudios({super.key});

  @override
  State<LocalAudios> createState() => _LocalAudiosState();
}

class _LocalAudiosState extends State<LocalAudios> {
  late final LocalAudioRepository audioService;
  late final PermissionHandler handler;
  late final LocalPlayerRepositoryImp player;

  @override
  void initState() {
    player = LocalPlayerRepositoryImp();
    audioService = LocalAudioRepository();
    handler = PermissionHandler();
    super.initState();
    getPermissions();
  }

  void getPermissions() async {
    await handler.requestPermission(PermissionType.audio);
    await handler.requestPermission(PermissionType.notification);
    await handler.requestPermission(PermissionType.storage);
    loadAudios();
  }

  void loadAudios() async {
    bool isStorageGranted = await handler.checkPermission(
      PermissionType.storage,
    );
    bool isAudioGranted = await handler.checkPermission(PermissionType.audio);
    if (isStorageGranted || isAudioGranted) {
      // ignore: use_build_context_synchronously
      BlocProvider.of<LocalBloc>(context).add(GetLocalAudios());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Sound Center"),
        actions: [],
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (text) {
              BlocProvider.of<LocalBloc>(context).add(Search(text.trim()));
            },
          ),
          Expanded(
            child: BlocBuilder<LocalBloc, LocalState>(
              builder: (BuildContext context, LocalState state) {
                if (state.status is LocalAudioStatus) {
                  LocalAudioStatus status = state.status as LocalAudioStatus;
                  return Column(
                    children: [
                      Expanded(child: AudioListTemplate(status.audios)),
                      if (LocalPlayerRepositoryImp().hasSource())
                        CurrentAudio(audioEntity: status.audios[status.index]),
                    ],
                  );
                }
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      CircularProgressIndicator(),
                      TextView("Scanning"),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
