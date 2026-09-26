import 'package:material_ui/material_ui.dart';
import 'package:sound_center/generated/l10n.dart';
import 'package:sound_center/shared/Repository/base_player_repository.dart';

class SpeedDialog extends StatefulWidget {
  const SpeedDialog({super.key, required this.imp});

  final BasePlayerRepository imp;

  @override
  State<SpeedDialog> createState() => _SpeedDialogState();
}

class _SpeedDialogState extends State<SpeedDialog> {
  late double speed;

  @override
  void initState() {
    speed = widget.imp.getSpeed();
    super.initState();
  }

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
                Text(S.of(context).playSpeed),
                Text("$speed x", textDirection: TextDirection.ltr),
              ],
            ),
            Slider(
              value: speed,
              min: 0.25,
              max: 3.0,
              label: speed.toStringAsFixed(2),
              divisions: 275,
              inactiveColor: Colors.grey,
              onChangeEnd: (value) async {
                speed = double.parse(value.toStringAsFixed(2));
                await widget.imp.setSpeed(speed);
                setState(() {});
              },
              onChanged: (value) {
                setState(() {
                  speed = double.parse(value.toStringAsFixed(2));
                });
              },
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
        await widget.imp.setSpeed(speed);
        setState(() {
          this.speed = speed;
        });
      },
      icon: Text("${speed}x", textDirection: TextDirection.ltr),
    );
  }
}
