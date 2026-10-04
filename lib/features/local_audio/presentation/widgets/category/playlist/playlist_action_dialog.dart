// ignore_for_file: use_build_context_synchronously

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/playlist/create_playlist_dialog.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';

class PlaylistActionDialog extends StatefulWidget {
  const PlaylistActionDialog({
    super.key,
    required this.playlistId,
    required this.title,
  });

  final int playlistId;
  final String title;

  @override
  State<PlaylistActionDialog> createState() => _PlaylistActionDialogState();
}

class _PlaylistActionDialogState extends State<PlaylistActionDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 15,
          mainAxisSize: .min,
          children: [
            TextButton(
              onPressed: () async {
                bool res =
                    await showDialog(
                      context: context,
                      builder: (_) => CreatePlaylistDialog(
                        playlistId: widget.playlistId,
                        title: widget.title,
                      ),
                    ) ??
                    false;
                if (res) Navigator.pop(context);
              },
              child: Text(S.of(context).editTitle),
            ),
            TextButton(
              onPressed: () async {
                bool res =
                    await showDialog(
                      context: context,
                      builder: (_) => ConfirmDialog(),
                    ) ??
                    false;
                if (res) {
                  BlocProvider.of<LocalBloc>(
                    context,
                  ).add(DeletePlaylist(playlist: widget.playlistId));
                  Navigator.pop(context);
                }
              },
              child: Text(S.of(context).delete),
            ),
          ],
        ),
      ),
    );
  }
}
