import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/util/multi_select_controller.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/order_menu.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({
    super.key,
    required this.onQueryChanged,
    required this.index,
    required this.onOrderChange,
    this.onShare,
    this.onDelete,
  });

  final ValueChanged<String> onQueryChanged;
  final Function(AudioColumns, bool) onOrderChange;
  final ValueChanged<Set<Object>>? onShare;
  final ValueChanged<Set<Object>>? onDelete;

  final int? index;

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  bool _showSearch = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.heightOf(context) / 100;
    if (MediaQuery.orientationOf(context) == .landscape) {
      height = MediaQuery.heightOf(context) / 50;
    }
    return ValueListenableBuilder<bool>(
      valueListenable: MultiSelectController.multiSelect,
      builder: (context, active, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showSearch ? height * 9 : height * 7,
        child: active ? _buildSelectionBar(context) : _buildDefaultBar(context),
      ),
    );
  }

  Widget _buildSelectionBar(BuildContext context) {
    return ValueListenableBuilder<Set<Object>>(
      valueListenable: MultiSelectController.selected,
      builder: (context, selected, _) => Row(
        children: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
            ),
            onPressed: _toggleSearch,
          ),
          if (_showSearch)
            Expanded(
              child: TextFieldBox(
                controller: _controller,
                textInputAction: TextInputAction.search,
                maxLines: 1,
                autofocus: true,
                hintText: S.of(context).searchHint,
                onChanged: (text) => widget.onQueryChanged(text.trim()),
              ),
            )
          else
            const Spacer(),

          Text('${selected.length}'),
          const SizedBox(width: 10),
          if (widget.index != 2)
            MediaControllerButton(
              svg: 'assets/icons/share.svg',
              height: 42,
              width: 42,
              onPressed: selected.isEmpty
                  ? null
                  : () => widget.onShare?.call(selected),
            ),
          MediaControllerButton(
            svg: 'assets/icons/trash-can.svg',
            height: 42,
            width: 42,
            onPressed: selected.isEmpty
                ? null
                : () => widget.onDelete?.call(selected),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
          ),
          onPressed: _toggleSearch,
        ),
        if (_showSearch)
          Expanded(
            child: TextFieldBox(
              controller: _controller,
              textInputAction: TextInputAction.search,
              maxLines: 1,
              autofocus: true,
              hintText: S.of(context).searchHint,
              onChanged: (text) => widget.onQueryChanged(text.trim()),
            ),
          ),
        if (!_showSearch) const Spacer(),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axis: Axis.horizontal,
            child: Center(
              child: ScaleTransition(scale: animation, child: child),
            ),
          ),
          child: widget.index != null && widget.index! > 1
              ? const SizedBox.shrink(key: ValueKey('hidden'))
              : Row(
                  key: const ValueKey('visible'),
                  mainAxisSize: .min,
                  children: [
                    if (widget.index != null)
                      MediaControllerButton(
                        svg: 'assets/icons/shuffle.svg',
                        height: 42,
                        width: 42,
                        onPressed: _shufflePlay,
                      ),
                    OrderMenu(onChange: widget.onOrderChange),
                  ],
                ),
        ),
      ],
    );
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (!_showSearch) {
      _controller.clear();
      widget.onQueryChanged('');
    }
  }

  void _shufflePlay() {
    final bloc = context.read<LocalBloc>();

    if (AudioUtil.allAudios.isEmpty) return;

    LocalPlayerRepositoryImp().shuffleMode = ShuffleMode.shuffle;
    bloc.add(
      PlayAudio(
        audios: AudioUtil.allAudios,
        index: Random().nextInt(AudioUtil.allAudios.length),
      ),
    );
  }
}
