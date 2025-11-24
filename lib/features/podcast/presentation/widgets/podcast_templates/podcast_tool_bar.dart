import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/podcast/presentation/bloc/podcast_bloc.dart';
import 'package:sound_center/features/podcast/presentation/pages/downloaded_episodes.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/rss_feed_dialog.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class PodcastToolBar extends StatefulWidget {
  const PodcastToolBar({super.key});

  @override
  State<PodcastToolBar> createState() => _PodcastToolBarState();
}

class _PodcastToolBarState extends State<PodcastToolBar> {
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
                hintText: S.of(context).searchHint,
                autofocus: true,
                onChanged: (text) {
                  if (text.trim().isEmpty) {
                    BlocProvider.of<PodcastBloc>(
                      context,
                    ).add(GetSubscribedPodcasts());
                  }
                },
                onSubmitted: (text) {
                  BlocProvider.of<PodcastBloc>(
                    context,
                  ).add(SearchPodcast(text.trim()));
                },
              ),
            ),
          if (!_showSearch) const Spacer(),
          IconButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => RssFeedDialog());
            },
            icon: Icon(Icons.rss_feed_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DownloadedEpisodes()),
              );
            },
            icon: Icon(Icons.download_rounded),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);

    if (!_showSearch) {
      final text = _controller.text.trim();
      if (text.isNotEmpty) {
        context.read<PodcastBloc>().add(GetSubscribedPodcasts());
      }
      _controller.clear();
    }
  }
}
