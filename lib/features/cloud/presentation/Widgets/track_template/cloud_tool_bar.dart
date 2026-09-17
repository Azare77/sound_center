import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/track_template/filter_dialog.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/features/cloud/presentation/pages/cloud.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/confirm_dialog.dart';
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
  late CloudBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<CloudBloc>(context);
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
    double height = MediaQuery.heightOf(context) / 100;
    final orientation = MediaQuery.orientationOf(context);
    if (orientation == .landscape) {
      height = MediaQuery.heightOf(context) / 50;
    }
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
          if (!_showSearch) const Spacer(),
          IconButton(
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (_) => ConfirmDialog(),
              );
              if (confirm ?? false) {
                bloc.add(ClearHistory());
              }
            },
            icon: Icon(Icons.delete_rounded),
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
