import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key, this.playlistId, this.title});

  final int? playlistId;
  final String? title;

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  TextEditingController title = TextEditingController();

  void submit(String title) {
    if (title.trim().isEmpty) return;
    final bloc = BlocProvider.of<LocalBloc>(context);
    if (widget.playlistId == null) {
      PlaylistEntity playlist = PlaylistEntity(
        id: 0,
        title: title.trim(),
        order: 0,
        itemCount: 0,
        totalDuration: 0,
        audios: [],
      );
      bloc.add(CreatePlaylist(playlist: playlist));
    } else {
      bloc.add(
        RenamePlaylist(playlistId: widget.playlistId!, newTitle: title.trim()),
      );
    }
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    if (widget.title != null) {
      title.text = widget.title!;
    }
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
            TextFieldBox(
              controller: title,
              autofocus: true,
              onSubmitted: submit,
              labelText: S.of(context).title,
              maxLines: 1,
              maxLength: 250,
              textInputAction: TextInputAction.go,
            ),
            ElevatedButton(
              onPressed: () => submit(title.text),
              child: Text(S.of(context).ok),
            ),
          ],
        ),
      ),
    );
  }
}
