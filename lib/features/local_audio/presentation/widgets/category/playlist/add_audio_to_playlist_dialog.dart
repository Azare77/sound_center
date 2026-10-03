import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/database/shared_preferences/app_setting_storage.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_list_template.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/tool_bar.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/glass.dart';

class AddAudioToPlaylistDialog extends StatefulWidget {
  const AddAudioToPlaylistDialog({super.key, required this.playlistId});

  final int playlistId;

  @override
  State<AddAudioToPlaylistDialog> createState() =>
      _AddAudioToPlaylistDialogState();
}

class _AddAudioToPlaylistDialogState extends State<AddAudioToPlaylistDialog> {
  List<AudioEntity> audios = [];
  List<AudioEntity> selected = [];
  final List<AudioEntity> allAudios = AudioUtil.allAudios;

  @override
  void initState() {
    audios = allAudios;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppSettingStorage.getPlayerStyle();
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Glass(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: 25,
        opacity: style == PlayerStyle.solid ? 1 : null,
        blur: style == PlayerStyle.solid ? 0 : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            spacing: 15,
            children: [
              ToolBar(
                onQueryChanged: filter,
                onOrderChange: (column, desc) {
                  setState(() {
                    audios = AudioUtil.sort(audios, column, desc);
                  });
                },
                index: null,
              ),
              Expanded(
                child: AudioListTemplate(
                  audios,
                  multipleSelect: true,
                  onAudioTap: (audio) {
                    if (selected.contains(audio)) {
                      selected.remove(audio);
                    } else {
                      selected.add(audio);
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<LocalBloc>(context).add(
                    AddToPlaylist(
                      playlistId: widget.playlistId,
                      audios: selected,
                    ),
                  );
                  Navigator.pop(context, selected);
                },
                child: Text(S.of(context).ok),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void filter(String name) {
    name = name.trim().toLowerCase();
    if (name.isEmpty) {
      audios = allAudios;
    } else {
      audios = allAudios
          .where((item) => item.title.toLowerCase().contains(name))
          .toList();
    }
    setState(() {});
  }
}
