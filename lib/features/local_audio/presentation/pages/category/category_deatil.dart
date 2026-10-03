// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/core_view/current_media.dart';
import 'package:sound_center/database/shared_preferences/loca_order_storage.dart';
import 'package:sound_center/features/local_audio/data/repositories/local_player_rpository_imp.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/LocalAudio/audio_list_template.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/tool_bar.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class CategoryDetail extends StatefulWidget {
  const CategoryDetail({
    super.key,
    required this.title,
    required this.category,
  });

  final String title;
  final Category category;

  @override
  State<CategoryDetail> createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  final LocalPlayerRepositoryImp repository = LocalPlayerRepositoryImp();
  bool toolbarCollapsed = false;
  List<AudioEntity> allAudios = [];
  List<AudioEntity> audios = [];
  StreamSubscription<AudioEntity?>? _audioSub;

  void _init() {
    allAudios = AudioUtil.allAudios;
    final title = widget.title.trim();
    switch (widget.category) {
      case Category.allSongs:
        throw UnimplementedError();
      case Category.favorites:
        throw UnimplementedError();
      case Category.playlists:
        throw UnimplementedError();
      case Category.artists:
        allAudios = allAudios
            .where((audio) => audio.artist.trim() == title)
            .toList();
      case Category.albums:
        allAudios = allAudios
            .where((audio) => audio.album.trim() == title)
            .toList();
      case Category.genres:
        allAudios = allAudios
            .where((audio) => audio.genre.trim() == title)
            .toList();
      case Category.folders:
        allAudios = allAudios
            .where(
              (audio) =>
                  File(
                    audio.path,
                  ).parent.path.split(Platform.pathSeparator).last.trim() ==
                  title,
            )
            .toList();
    }
    final desc = LocalOrderStorage.getSavedDesc();
    final order = LocalOrderStorage.getSavedColumn();
    audios = AudioUtil.sort(allAudios, order, desc);

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _audioSub = repository.audioChangedStream.listen((ms) async {
      setState(() {});
    });
    _init();
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          Column(
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
                child: audios.isEmpty ? Loading() : AudioListTemplate(audios),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CurrentMedia(key: Key("podcastDetail")),
          ),
        ],
      ),
    );
  }

  void filter(String name) {
    name = name.trim().toLowerCase();
    if (name.isEmpty) {
      audios = allAudios;
    } else {
      audios = audios
          .where((item) => item.title.toLowerCase().contains(name))
          .toList();
    }
    setState(() {});
  }
}
