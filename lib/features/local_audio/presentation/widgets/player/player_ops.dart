import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/speed_dialog.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';

class PlayerOps extends StatelessWidget {
  const PlayerOps({super.key});

  void _delete(BuildContext context) async {
    bool res =
        await showDialog(context: context, builder: (_) => ConfirmDialog()) ??
        false;
    if (res) {
      BlocProvider.of<LocalBloc>(
        // ignore: use_build_context_synchronously
        context,
      ).add(DeleteAudio(LocalPlayerRepositoryImp().getCurrentAudio!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onDoubleTap: () {
            showDialog(context: context, builder: (_) => SpeedDialog());
          },
          child: MediaControllerButton(
            width: 50,
            height: 50,
            onPressed: () => _delete(context),
            svg: "assets/icons/trash-can.svg",
          ),
        ),
        SizedBox(
          width: 40,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
        ),
        MediaControllerButton(
          width: 50,
          height: 50,
          onPressed: () async {
            if (!Platform.isLinux) {
              final song = LocalPlayerRepositoryImp().getCurrentAudio;
              SharePlus.instance.share(ShareParams(files: [XFile(song!.path)]));
            }
          },
          svg: "assets/icons/share.svg",
        ),
      ],
    );
  }
}
