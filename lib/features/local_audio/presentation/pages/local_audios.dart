import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/core/util/permission/permission_handler.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_audio_repository.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_list_template.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/tool_bar.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class LocalAudios extends StatefulWidget {
  const LocalAudios({super.key});

  @override
  State<LocalAudios> createState() => _LocalAudiosState();
}

class _LocalAudiosState extends State<LocalAudios> with WidgetsBindingObserver {
  late final LocalAudioRepository audioService;
  late final PermissionHandler handler;
  late final LocalPlayerRepositoryImp player;
  late final ToolBar toolBar;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    player = LocalPlayerRepositoryImp();
    audioService = LocalAudioRepository();
    handler = PermissionHandler();
    toolBar = ToolBar();
    getPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> getPermissions() async {
    try {
      await handler.requestPermission(PermissionType.audio);
      await handler.requestPermission(PermissionType.notification);
      await handler.requestPermission(PermissionType.storage);
    } catch (_) {
    } finally {
      loadAudios();
    }
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
    return Column(
      children: [
        toolBar,
        Expanded(
          child: BlocBuilder<LocalBloc, LocalState>(
            builder: (BuildContext context, LocalState state) {
              if (state.status is LocalAudioStatus) {
                LocalAudioStatus status = state.status as LocalAudioStatus;
                return AudioListTemplate(status.audios);
              }
              return Loading(label: "Scanning");
            },
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        loadAudios();
        return;
      default:
        return;
    }
  }
}
