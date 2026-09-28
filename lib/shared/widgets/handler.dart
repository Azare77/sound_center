import 'package:material_ui/material_ui.dart';

class Handler extends StatelessWidget {
  const Handler({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).iconTheme.color,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
    );
  }
}
