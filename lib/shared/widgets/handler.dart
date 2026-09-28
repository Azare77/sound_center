import 'package:material_ui/material_ui.dart';
import 'package:sound_center/shared/theme/themes.dart';

class Handler extends StatelessWidget {
  const Handler({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ThemeManager.current.iconColor,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
    );
  }
}
