import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/pages/category/category_deatil.dart';
import 'package:sound_center/features/local_audio/presentation/util/multi_select_controller.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/category_template.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class CategoryListTemplate extends StatefulWidget {
  const CategoryListTemplate({
    super.key,
    required this.category,
    required this.items,
  });

  final Category category;
  final List<dynamic> items;

  @override
  State<CategoryListTemplate> createState() => _CategoryListTemplateState();
}

class _CategoryListTemplateState extends State<CategoryListTemplate> {
  final _scrollController = ScrollController();
  final playerRepo = LocalPlayerRepositoryImp();

  late final IconData icon;

  @override
  void initState() {
    switch (widget.category) {
      case Category.allSongs:
        break;
      case Category.favorites:
        break;
      case Category.playlists:
        icon = Icons.playlist_play_rounded;
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
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(child: TextView(S.of(context).noAudio));
    }
    return ValueListenableBuilder<bool>(
      valueListenable: MultiSelectController.multiSelect,
      builder: (context, active, _) => ValueListenableBuilder<Set<Object>>(
        valueListenable: MultiSelectController.selected,
        builder: (context, _, __) => Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          interactive: true,
          child: ListView.builder(
            itemCount: widget.items.length,
            controller: _scrollController,
            itemExtent: LIST_ITEM_HEIGHT,
            padding: const EdgeInsets.only(bottom: 120),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isSelected = MultiSelectController.isSelected(item);

              void onToggle() => MultiSelectController.toggle(item);

              return InkWell(
                onTap: () {
                  if (active) {
                    onToggle();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetail(
                        title: item.name,
                        category: widget.category,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  if (active) return;
                  MultiSelectController.enable(item); // req 1
                },
                child: CategoryTemplate(
                  key: ValueKey(item.name),
                  item: item,
                  icon: icon,
                  isMultiple: active,
                  isSelected: isSelected,
                  onChanged: (value) {
                    if (value == null) return;
                    onToggle();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
