import 'package:flutter/material.dart';
import 'package:sound_center/features/stream/presentation/pages/stream.dart';
import 'package:sound_center/features/stream/presentation/widgets/direct_link_dialog.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';

class StreamToolBar extends StatefulWidget {
  const StreamToolBar({super.key});

  @override
  State<StreamToolBar> createState() => _StreamToolBarState();
}

class _StreamToolBarState extends State<StreamToolBar> {
  bool _showSearch = false;
  final _controller = TextEditingController();
  late ValueNotifier searchNotifier;

  @override
  void initState() {
    super.initState();
    searchNotifier = StreamSearchController.showSearchField;
    searchNotifier.addListener(() {
      if (_showSearch) {
        _controller.clear();
        setState(() {
          _showSearch = StreamSearchController.showSearchField.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    searchNotifier.dispose();
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
                  if (text.trim().isEmpty) {}
                },
                onSubmitted: (text) {},
              ),
            ),
          if (!_showSearch) const Spacer(),
          IconButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => DirectLinkDialog());
            },
            icon: Icon(Icons.link_rounded),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    StreamSearchController.showSearchField.value = _showSearch;
    if (!_showSearch) {
      _controller.clear();
    }
  }
}
