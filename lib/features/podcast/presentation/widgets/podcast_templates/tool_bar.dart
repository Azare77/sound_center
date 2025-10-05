import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/order_menu.dart';
import 'package:sound_center/shared/Repository/player_repository.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({super.key});

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  bool _showSearch = false;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search_rounded),
              onPressed: _toggleSearch,
            ),

            IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              onPressed: _shufflePlay,
            ),
            const Spacer(),
            OrderMenu(),
          ],
        ),
        AnimatedCrossFade(
          crossFadeState: _showSearch
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 200),
          firstChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'what do you want?',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                BlocProvider.of<LocalBloc>(
                  context,
                ).add(Search(query: text.trim()));
              },
            ),
          ),
          secondChild: SizedBox.shrink(),
        ),
      ],
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
