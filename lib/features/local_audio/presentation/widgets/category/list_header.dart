import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.title,
    required this.audios,
    required this.category,
    this.playlistRename,
  });

  final String title;
  final Function? playlistRename;
  final List<AudioEntity> audios;
  final Category category;

  void _shufflePlay(BuildContext context) {
    final bloc = context.read<LocalBloc>();
    final imp = LocalPlayerRepositoryImp();
    if (audios.isEmpty) return;

    imp.shuffleMode = ShuffleMode.shuffle;
    bloc.add(PlayAudio(audios: audios, index: Random().nextInt(audios.length)));
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme cs = Theme.of(context).colorScheme;
    TextTheme tt = Theme.of(context).textTheme;
    final bloc = BlocProvider.of<LocalBloc>(context);

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    IconData icon;
    switch (category) {
      case Category.playlists:
        icon = Icons.queue_music_rounded;
        break;
      case Category.artists:
        icon = Icons.person_rounded;
        break;
      case Category.albums:
        icon = Icons.album_rounded;
        break;
      case Category.genres:
        icon = Icons.music_note_rounded;
        break;
      case Category.folders:
        icon = Icons.folder_rounded;
        break;
      default:
        icon = Icons.music_note_rounded;
    }

    // Scale down everything when the available height is tight (landscape).
    final double avatarSize = isLandscape ? 40 : 50;
    final double iconSize = isLandscape ? 22 : 30;
    final double verticalPadding = isLandscape ? 10 : 20;
    final double bottomPadding = isLandscape ? 12 : 24;

    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isLandscape ? 14 : 18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: isLandscape ? 10 : 16,
            offset: Offset(0, isLandscape ? 3 : 6),
          ),
        ],
      ),
      child: Hero(
        tag: title,
        child: Icon(icon, color: cs.onPrimary, size: iconSize),
      ),
    );

    final titleBlock = Expanded(
      child: Column(
        spacing: isLandscape ? 2 : 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              Expanded(
                child: ScrollingText(
                  title,
                  style: (isLandscape ? tt.titleMedium : tt.titleLarge)
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimaryContainer,
                      ),
                ),
              ),
              if (category == Category.playlists)
                IconButton(
                  onPressed: () => playlistRename?.call(),
                  iconSize: 18,
                  visualDensity: isLandscape
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                  padding: isLandscape ? EdgeInsets.zero : null,
                  constraints: isLandscape
                      ? const BoxConstraints(minWidth: 28, minHeight: 28)
                      : null,
                  icon: Icon(Icons.edit_rounded, color: cs.onPrimaryContainer),
                ),
            ],
          ),
          if (!isLandscape)
            Text(
              '${S.of(context).tracks} : ${audios.length}',
              style: tt.bodyMedium?.copyWith(
                color: cs.onPrimaryContainer.withValues(alpha: 0.75),
              ),
            ),
        ],
      ),
    );

    final playButton = FilledButton.icon(
      onPressed: audios.isEmpty
          ? null
          : () => bloc.add(PlayAudio(audios: audios, index: 0)),
      label: Text(S.of(context).play),
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isLandscape ? 8 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    final shuffleButton = OutlinedButton.icon(
      onPressed: audios.isEmpty ? null : () => _shufflePlay(context),
      label: Text(S.of(context).shufflePlay),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isLandscape ? 8 : 12),
        foregroundColor: cs.onPrimaryContainer,
        side: BorderSide(color: cs.onPrimaryContainer.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(20, verticalPadding, 20, bottomPadding),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).appBarTheme.backgroundColor!,
            Theme.of(
              context,
            ).appBarTheme.backgroundColor!.withValues(alpha: 0.6),
          ],
        ),
      ),
      // In landscape everything sits in ONE row (avatar, title, buttons)
      // so the header only ever costs one row of height instead of two
      // stacked blocks (info row + button row).
      child: isLandscape
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12,
              children: [
                avatar,
                titleBlock,
                SizedBox(width: 110, child: playButton),
                SizedBox(width: 150, child: shuffleButton),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 18,
              children: [
                Row(spacing: 15, children: [avatar, titleBlock]),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(child: playButton),
                    Expanded(child: shuffleButton),
                  ],
                ),
              ],
            ),
    );
  }
}
