import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/order_menu.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({super.key});

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
    double height = MediaQuery.of(context).size.height / 100;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _showSearch ? height * 9 : height * 7,
      child: Row(
        children: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search_rounded),
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
                onChanged: (text) {
                  BlocProvider.of<LocalBloc>(
                    context,
                  ).add(Search(query: text.trim()));
                },
              ),
            ),
          if (!_showSearch) const Spacer(),
          MediaControllerButton(
            svg: 'assets/icons/shuffle.svg',
            height: 42,
            width: 42,
            onPressed: _shufflePlay,
          ),
          OrderMenu(),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);

    if (!_showSearch) {
      final text = _controller.text.trim();
      if (text.isNotEmpty) {
        context.read<LocalBloc>().add(Search());
      }
      _controller.clear();
    }
  }

  void _shufflePlay() {
    final bloc = context.read<LocalBloc>();
    final status = bloc.state.status as LocalAudioStatus;

    if (status.audios.isEmpty) return;

    LocalPlayerRepositoryImp().shuffleMode = ShuffleMode.shuffle;
    final randomIndex = Random().nextInt(status.audios.length);
    bloc.add(PlayAudio(randomIndex));
  }
}
