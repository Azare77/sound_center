import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/cloud/domain/entity/cloud_entity.dart';
import 'package:sound_center/features/cloud/presentation/Widgets/track_template/cloud_list_template.dart';

class CloudHistoryList extends StatelessWidget {
  const CloudHistoryList({super.key, required this.history});

  final CloudEntity history;

  @override
  Widget build(BuildContext context) {
    return CloudListTemplate(history);
  }
}
