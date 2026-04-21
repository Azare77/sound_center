import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/player/header_image.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/speed_dialog.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/shared/widgets/media_controller_button.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class StreamHeader extends StatefulWidget {
  const StreamHeader({super.key});

  @override
  State<StreamHeader> createState() => _StreamHeaderState();
}

class _StreamHeaderState extends State<StreamHeader> {
  late final PageController controller;

  int _currentIndex = 0;
  bool _isScrolling = false;
  List<dynamic> currentPlayList = [];
  late final StreamPlayerRepositoryImp imp;

  @override
  void initState() {
    super.initState();
    imp = StreamPlayerRepositoryImp();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScrollEnd() async {
    _isScrolling = false;
    await Future.delayed(Duration(milliseconds: 250));
    if (_isScrolling) return;
    int page = controller.page?.round() ?? 0;
    int change = page - _currentIndex;
    if (change == 0) return;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreamBloc, StreamState>(
      builder: (BuildContext context, StreamState state) {
        final song = imp.getCurrentStream!;
        late final String title;
        late final String? artist;
        final currentStream = imp.getCurrentStream;
        if (currentStream is AudioModel) {
          title = currentStream.title;
          artist = currentStream.artist;
        } else if (currentStream is Source) {
          title = currentStream.title ?? '';
          artist = null;
        }
        currentPlayList = imp.getPlayList();
        _currentIndex = 0;
        _jumpToCorrectPage();
        return Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (_) => SpeedDialog());
                  },
                  icon: Icon(Icons.speed_rounded),
                ),
                SizedBox(
                  width: 40,
                  height: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
                MediaControllerButton(
                  width: 50,
                  height: 50,
                  onPressed: () async {
                    if (!Platform.isLinux) {
                      SharePlus.instance.share(
                        ShareParams(files: [XFile(song.path)]),
                      );
                    }
                  },
                  svg: "assets/icons/share.svg",
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8 - 30,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollStartNotification) {
                    _isScrolling = true;
                  }
                  if (notification is ScrollEndNotification) {
                    onScrollEnd();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: controller,
                  restorationId: title,
                  itemCount: currentPlayList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final currentStream = imp.getCurrentStream;
                    Uint8List? cover;
                    late final String url;
                    if (currentStream is AudioModel) {
                      cover = currentStream.cover;
                      url = currentStream.path;
                    } else if (currentStream is Source) {
                      url = currentStream.listenUrl;
                    }
                    return HeaderImage(
                      key: ValueKey("$url-${cover?.length.toString()}"),
                      id: -1,
                      cover: cover,
                    );
                  },
                ),
              ),
            ),
            ScrollingText(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            if (artist != null)
              ScrollingText(
                artist,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
          ],
        );
      },
    );
  }

  void _jumpToCorrectPage() {
    if (controller.hasClients) {
      _isScrolling = true;
      controller.jumpToPage(_currentIndex);
      _isScrolling = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        _isScrolling = true;
        controller.jumpToPage(_currentIndex);
        _isScrolling = false;
      }
    });
  }
}
