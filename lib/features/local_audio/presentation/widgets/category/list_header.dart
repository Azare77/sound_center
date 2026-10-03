import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.title,
    required this.audios,
    required this.category,
  });

  final String title;
  final List<AudioEntity> audios;
  final Category category;

  @override
  Widget build(BuildContext context) {
    ColorScheme cs = Theme.of(context).colorScheme;
    TextTheme tt = Theme.of(context).textTheme;
    final bloc = BlocProvider.of<LocalBloc>(context);
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

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          Row(
            spacing: 15,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.tertiary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: cs.onPrimary, size: 30),
              ),
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScrollingText(
                      title,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '${S.of(context).tracks} : ${audios.length}',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            spacing: 10,
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: audios.isEmpty
                      ? null
                      : () => bloc.add(PlayAudio(audios: audios, index: 0)),
                  label: Text(S.of(context).play),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: audios.isEmpty
                      ? null
                      : () {
                          final shuffled = List<AudioEntity>.from(audios)
                            ..shuffle();
                          bloc.add(PlayAudio(audios: shuffled, index: 0));
                        },
                  label: Text(S.of(context).shufflePlay),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: cs.onPrimaryContainer,
                    side: BorderSide(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
