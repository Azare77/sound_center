import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/data/model/audio.dart';
import 'package:sound_center/features/stream/data/repository/stream_player_repository_imp.dart';
import 'package:sound_center/features/stream/domain/entity/stream_info.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_image.dart';
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
  final GlobalKey _sliderKey = GlobalKey();
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
        final slider = NotificationListener<ScrollNotification>(
          key: _sliderKey,
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
              String? coverUrl;
              late final String url;
              if (currentStream is AudioModel) {
                cover = currentStream.cover;
                url = currentStream.path;
              } else if (currentStream is Source) {
                url = currentStream.listenUrl;
                coverUrl = currentStream.cover;
              }
              return StreamImage(
                key: ValueKey("$url-${cover?.length.toString()}-$coverUrl"),
                id: -1,
                cover: cover,
                coverUrl: coverUrl,
              );
            },
          ),
        );
        final orientation = MediaQuery.orientationOf(context);
        return Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            orientation == Orientation.landscape
                ? Expanded(
                    child: Center(
                      child: AspectRatio(aspectRatio: 1, child: slider),
                    ),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8 - 30,
                    child: slider,
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
