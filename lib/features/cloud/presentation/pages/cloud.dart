// ignore_for_file: use_build_context_synchronously

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/cloud_history_list.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/cloud_list_template.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/cloud_tool_bar.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:sound_center/features/cloud/presentation/bloc/cloud_status.dart';
import 'package:sound_center/shared/widgets/loading.dart';

class CloudSearchController {
  static final ValueNotifier<bool> showSearchField = ValueNotifier(true);
}

class CloudPage extends StatelessWidget {
  const CloudPage({super.key});

  bool resetPodcastPage(BuildContext context) {
    final bloc = BlocProvider.of<CloudBloc>(context);
    final status = bloc.state.status;
    CloudSearchController.showSearchField.value = false;
    if (status is! LoadingCloud) {
      bloc.add(LoadHistory());
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CloudToolBar(),
        Expanded(
          child: BlocBuilder<CloudBloc, CloudState>(
            builder: (BuildContext context, CloudState state) {
              if (state.status is SearchResultStatus) {
                SearchResultStatus status = state.status as SearchResultStatus;
                return CloudListTemplate(status.searchResult);
              }
              if (state.status is CloudHistory) {
                CloudHistory status = state.status as CloudHistory;
                return CloudHistoryList(history: status.history);
              }
              return Loading();
            },
          ),
        ),
      ],
    );
  }
}
