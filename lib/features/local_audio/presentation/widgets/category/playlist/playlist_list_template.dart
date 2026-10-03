import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/local_audio/domain/entities/local_play_list.dart';
import 'package:sound_center/features/local_audio/presentation/pages/playlist.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/playlist/playlist_template.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class PlaylistListTemplate extends StatefulWidget {
  const PlaylistListTemplate(this.playlists, {super.key});

  final List<PlaylistEntity> playlists;

  @override
  State<PlaylistListTemplate> createState() => _PlaylistListTemplateState();
}

class _PlaylistListTemplateState extends State<PlaylistListTemplate> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.playlists.isEmpty) {
      return Center(child: TextView(S.of(context).noAudio));
    }
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      interactive: true,
      child: ListView.builder(
        itemCount: widget.playlists.length,
        controller: _scrollController,
        itemExtent: LIST_ITEM_HEIGHT,
        padding: const EdgeInsets.only(bottom: 120),
        itemBuilder: (context, index) {
          final list = widget.playlists[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Playlist(playlist: list)),
              );
            },
            child: PlaylistTemplate(item: list),
          );
        },
      ),
    );
  }
}
