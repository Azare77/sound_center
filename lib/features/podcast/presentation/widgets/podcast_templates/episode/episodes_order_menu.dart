import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/domain/repository/podcast_repository.dart';
import 'package:sound_center/shared/widgets/text_view.dart'; // اگر TextView یک ویجت سفارشی‌ت باشه

class EpisodesOrderMenu extends StatefulWidget {
  const EpisodesOrderMenu({super.key, required this.onChange});

  final Function(PodcastOrder) onChange;

  @override
  State<EpisodesOrderMenu> createState() => _EpisodesOrderMenuState();
}

class _EpisodesOrderMenuState extends State<EpisodesOrderMenu> {
  PodcastOrder currentColumn = PodcastOrder.NEWEST;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PodcastOrder>(
      icon: const Icon(Icons.sort_rounded),
      onSelected: (column) {
        setState(() {
          currentColumn = column;
        });
        widget.onChange.call(column);
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<PodcastOrder>>[
          _buildItem(PodcastOrder.NEWEST, currentColumn, 'Latest First'),
          _buildItem(PodcastOrder.OLDEST, currentColumn, 'Oldest First'),
          _buildItem(PodcastOrder.AZ, currentColumn, 'A-Z'),
          _buildItem(PodcastOrder.ZA, currentColumn, 'Z-A'),
        ];
      },

      // child: const Icon(Icons.sort_rounded),
    );
  }

  PopupMenuItem<PodcastOrder> _buildItem(
    PodcastOrder column,
    PodcastOrder current,
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
