import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_status.dart';
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
              onPressed: () {
                setState(() => _showSearch = !_showSearch);
                if (!_showSearch) {
                  if (_controller.text.trim().isNotEmpty) {
                    BlocProvider.of<LocalBloc>(context).add(Search());
                  }
                  _controller.clear();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.shuffle_rounded),
              onPressed: () {
                LocalPlayerRepositoryImp().shuffleMode = ShuffleMode.shuffle;
                LocalBloc bloc = BlocProvider.of<LocalBloc>(context);
                LocalAudioStatus status = bloc.state.status as LocalAudioStatus;
                int random = Random().nextInt(status.audios.length);
                bloc.add(PlayAudio(random));
              },
            ),
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
}
