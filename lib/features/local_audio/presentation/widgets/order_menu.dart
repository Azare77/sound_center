import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/database/shared_preferences/loca_order_storage.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/widgets/text_view.dart';

class OrderMenu extends StatefulWidget {
  const OrderMenu({super.key, required this.onChange});

  final Function(AudioColumns, bool) onChange;

  @override
  State<OrderMenu> createState() => _OrderMenuState();
}

class _OrderMenuState extends State<OrderMenu> {
  late bool desc;

  late AudioColumns currentColumn;

  @override
  void initState() {
    desc = LocalOrderStorage.getSavedDesc();
    currentColumn = LocalOrderStorage.getSavedColumn();
    super.initState();
  }

  void triggerChange() {
    widget.onChange.call(currentColumn, desc);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AudioColumns>(
      icon: const Icon(Icons.sort_rounded),
      onSelected: (column) {
        BlocProvider.of<LocalBloc>(context).add(Search(column: column));
        currentColumn = column;
        triggerChange();
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<AudioColumns>>[
          _buildItem(AudioColumns.title, currentColumn, S.of(context).title),
          _buildItem(AudioColumns.artist, currentColumn, S.of(context).artist),
          _buildItem(AudioColumns.album, currentColumn, S.of(context).album),
          _buildItem(
            AudioColumns.createdAt,
            currentColumn,
            S.of(context).createTime,
          ),
          _buildItem(
            AudioColumns.duration,
            currentColumn,
            S.of(context).duration,
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: null,
            enabled: false,
            child: StatefulBuilder(
              builder: (context, setMenuState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextView(S.of(context).descending),
                    Switch(
                      value: desc,
                      onChanged: (value) {
                        desc = value;
                        Storage.instance.prefs.setBool('desc', value);

                        setMenuState(() {});
                        triggerChange();
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ];
      },
    );
  }

  PopupMenuItem<AudioColumns> _buildItem(
    AudioColumns column,
    AudioColumns current,
    String label,
  ) {
    return PopupMenuItem(
      value: column,
      child: Row(
        children: [
          if (current == column) const Icon(Icons.check, size: 18),
          if (current != column) const SizedBox(width: 8),
          TextView(label),
        ],
      ),
    );
  }
}
