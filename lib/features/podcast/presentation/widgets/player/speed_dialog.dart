import 'package:flutter/material.dart';
import 'package:sound_center/features/podcast/data/repository/podcast_player_rpository_imp.dart';

class SpeedDialog extends StatefulWidget {
  const SpeedDialog({super.key});

  @override
  State<SpeedDialog> createState() => _SpeedDialogState();
}

class _SpeedDialogState extends State<SpeedDialog> {
  final PodcastPlayerRepositoryImp imp = PodcastPlayerRepositoryImp();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Play Speed"),
                Text(
                  "${imp.getSpeed().toString()}x",
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
            Wrap(
              textDirection: TextDirection.ltr,
              children: [
                speedButton(0.5),
                speedButton(1.0),
                speedButton(1.25),
                speedButton(1.5),
                speedButton(1.75),
                speedButton(2),
                speedButton(3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget speedButton(double speed) {
    return IconButton(
      onPressed: () async {
        await imp.setSpeed(speed);
        setState(() {});
      },
      icon: Text("${speed}x", textDirection: TextDirection.ltr),
    );
  }
}
