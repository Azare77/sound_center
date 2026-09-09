import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/track_template/filter_dialog.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/features/cloud/presentation/pages/cloud.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_field_box.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart';

class CloudToolBar extends StatefulWidget {
  const CloudToolBar({super.key});

  @override
  State<CloudToolBar> createState() => _CloudToolBarState();
}

class _CloudToolBarState extends State<CloudToolBar> {
  bool _showSearch = false;
  final _controller = TextEditingController();
  late ValueNotifier searchNotifier;
  SearchFilter type = SearchFilter.none;

  @override
  void initState() {
    super.initState();
    searchNotifier = CloudSearchController.showSearchField;
    searchNotifier.addListener(() {
      if (_showSearch) {
        _controller.clear();
        setState(() {
          _showSearch = CloudSearchController.showSearchField.value;
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
    double height = MediaQuery
        .of(context)
        .size
        .height / 100;
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
                hintText: S
                    .of(context)
                    .searchHint,
                autofocus: true,
                onSubmitted: (text) {
                  BlocProvider.of<CloudBloc>(
                    context,
                  ).add(SearchCloud(queryText: text.trim(), filter: type));
                },
                suffixIcon: Row(
                  mainAxisSize: .min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        final dialog = FilterDialog(filter: type);
                        showDialog(
                          context: context,
                          builder: (context) => dialog,
                        ).then((res) {
                          type = res;
                          setState(() {});
                        });
                      },
                      icon: Icon(
                        Icons.filter_alt_rounded,
                        color: type != SearchFilter.none ? Colors.blue : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    CloudSearchController.showSearchField.value = _showSearch;
    if (!_showSearch) {
      _controller.clear();
      BlocProvider.of<CloudBloc>(context).add(LoadHistory());
    }
  }
}
