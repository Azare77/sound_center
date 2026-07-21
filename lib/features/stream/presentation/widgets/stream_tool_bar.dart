import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/features/stream/presentation/bloc/stream_bloc.dart';
import 'package:sound_center/features/stream/presentation/pages/stream.dart';
import 'package:sound_center/features/stream/presentation/widgets/direct_link_dialog.dart';
import 'package:sound_center/features/stream/presentation/widgets/tool_bar/country_list_dialog.dart';
import 'package:sound_center/features/stream/presentation/widgets/tool_bar/language_list_dialog.dart';
import 'package:sound_center/features/stream/presentation/widgets/tool_bar/tag_list_dialog.dart';
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
  late final StreamBloc bloc;
  String? language;
  String? country;
  String? tags;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<StreamBloc>(context);
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
                suffixIcon: Row(
                  mainAxisSize: .min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final dialog = CountryListDialog(currentCode: country);
                        showDialog(
                          context: context,
                          builder: (context) => dialog,
                        ).then((res) {
                          country = res;
                          setState(() {});
                        });
                      },
                      icon: Icon(
                        Icons.language_rounded,
                        color: country != null ? Colors.blue : null,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final dialog = LanguageListDialog(
                          currentLanguage: language,
                        );
                        showDialog(
                          context: context,
                          builder: (context) => dialog,
                        ).then((res) {
                          language = res;
                          setState(() {});
                        });
                      },
                      icon: Icon(
                        Icons.translate_rounded,
                        color: language != null ? Colors.blue : null,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final dialog = TagListDialog(currentTag: tags);
                        showDialog(
                          context: context,
                          builder: (context) => dialog,
                        ).then((res) {
                          tags = res;
                          setState(() {});
                        });
                      },
                      icon: Icon(
                        Icons.sell_rounded,
                        color: tags != null ? Colors.blue : null,
                      ),
                    ),
                  ],
                ),
                onChanged: (text) {
                  if (text.trim().isEmpty) {
                    bloc.add(GetSubscribedStreams());
                  }
                },
                onSubmitted: (text) {
                  bloc.add(
                    SearchStream(
                      offset: 1,
                      name: text.trim(),
                      language: language,
                      countryCode: country,
                      tag: tags,
                    ),
                  );
                },
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
      bloc.add(GetSubscribedStreams());
    }
  }
}
