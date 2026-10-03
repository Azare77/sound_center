import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';

class ActionBar extends StatefulWidget {
  const ActionBar({
    super.key,
    required this.audios,
    required this.playlistId,
    required this.onDeleted,
  });

  final int playlistId;
  final List<AudioEntity> audios;
  final VoidCallback onDeleted;

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  void _delete(BuildContext context) async {
    final bloc = BlocProvider.of<LocalBloc>(context);
    bool res =
        await showDialog(context: context, builder: (_) => ConfirmDialog()) ??
        false;
    if (res) {
      // Make a copy of the list because onDeleted modifies the original list.
      final audios = List<AudioEntity>.from(widget.audios);
      bloc.add(
        RemoveFromPlaylist(playlistId: widget.playlistId, audios: audios),
      );
      widget.onDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          child: MediaControllerButton(
            width: 50,
            height: 50,
            onPressed: () => _delete(context),
            svg: "assets/icons/trash-can.svg",
          ),
        ),

        MediaControllerButton(
          width: 50,
          height: 50,
          onPressed: () async {
            if (!Platform.isLinux) {
              List<XFile> files = [];
              for (AudioEntity a in widget.audios) {
                files.add(XFile(a.path));
              }
              SharePlus.instance.share(ShareParams(files: files));
            }
          },
          svg: "assets/icons/share.svg",
        ),
      ],
    );
  }
}
