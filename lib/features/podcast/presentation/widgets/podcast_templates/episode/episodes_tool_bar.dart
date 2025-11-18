import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/domain/repository/podcast_repository.dart';
import 'package:sound_center/features/podcast/presentation/widgets/podcast_templates/episode/episodes_order_menu.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class EpisodesToolBar extends StatefulWidget {
  const EpisodesToolBar({
    super.key,
    required this.onChange,
    required this.onOrderChange,
  });

  final Function(String) onChange;
  final Function(PodcastOrder) onOrderChange;

  @override
  State<EpisodesToolBar> createState() => _EpisodesToolBarState();
}

class _EpisodesToolBarState extends State<EpisodesToolBar> {
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
                autofocus: true,
                textInputAction: TextInputAction.search,
                maxLines: 1,
                hintText: S.of(context).searchHint,
                onChanged: widget.onChange,
              ),
            ),
          if (!_showSearch) const Spacer(),
          EpisodesOrderMenu(onChange: widget.onOrderChange),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);

    if (!_showSearch) {
      final text = _controller.text.trim();
      if (text.isNotEmpty) {
        widget.onChange.call("");
      }
      _controller.clear();
    }
  }
}
