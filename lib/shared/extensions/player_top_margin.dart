import 'package:material_ui/material_ui.dart';

extension EdgeInsetsExtension on EdgeInsets {
  EdgeInsets addPlayerPadding({required bool isLandscape}) {
    final EdgeInsets edgeInsets = EdgeInsets.fromViewPadding(
      WidgetsBinding.instance.platformDispatcher.views.first.padding,
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio,
    );
    final paddingTop = edgeInsets.top;
    return copyWith(
      top: top + paddingTop,
      bottom: bottom + (isLandscape ? 5 : 0),
    );
  }
}
