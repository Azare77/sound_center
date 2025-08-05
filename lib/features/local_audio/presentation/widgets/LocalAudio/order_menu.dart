import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sound_center/database/shared_preferences/loca_order_storage.dart';
import 'package:sound_center/database/shared_preferences/shared_preferences.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/bloc/local_bloc.dart';
import 'package:sound_center/shared/widgets/text_view.dart'; // اگر TextView یک ویجت سفارشی‌ت باشه

class OrderMenu extends StatelessWidget {
  const OrderMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AudioColumns>(
      icon: const Icon(Icons.sort_rounded),
      onSelected: (column) {
        // اگر آیتم مربوط به سوییچ بود (مقدار خاص)
        BlocProvider.of<LocalBloc>(context).add(Search(column: column));
      },
      itemBuilder: (context) {
        final currentColumn = LocalOrderStorage.getSavedColumn();
        return <PopupMenuEntry<AudioColumns>>[
          _buildItem(AudioColumns.title, currentColumn, 'Title'),
          _buildItem(AudioColumns.artist, currentColumn, 'Artist'),
          _buildItem(AudioColumns.album, currentColumn, 'Album'),
          _buildItem(AudioColumns.createdAt, currentColumn, 'Create time'),
          _buildItem(AudioColumns.duration, currentColumn, 'Duration'),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: null,
            enabled: false,
            child: StatefulBuilder(
              builder: (context, setState) {
                final desc = LocalOrderStorage.getSavedDesc();
                return Row(
                  children: [
                    const TextView('Descending'),
                    const Spacer(),
                    Switch(
                      value: desc,
                      onChanged: (value) {
                        Storage.instance.prefs.setBool('desc', value);
                        BlocProvider.of<LocalBloc>(context).add(Search());
                        setState(() {});
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ];
      },

      // child: const Icon(Icons.sort_rounded),
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
