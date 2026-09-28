import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:sound_center/shared/theme/themes.dart';

class Glass extends StatelessWidget {
  const Glass({
    super.key,
    this.borderRadius = 0.0,
    required this.color,
    required this.child,
    this.blur,
    this.opacity,
    this.elevation = 0.0,
    this.useBorder = true,
    this.onlyTopBorderRadius = false,
  });

  final double borderRadius;
  final Color color;
  final double? blur;
  final double? opacity;
  final double elevation;
  final Widget child;
  final bool useBorder;
  final bool onlyTopBorderRadius;

  @override
  Widget build(BuildContext context) {
    final finalOpacity = opacity ?? ThemeManager.current.opacity;
    final finalBlur = blur ?? ThemeManager.current.blur;

    final border = onlyTopBorderRadius
        ? BorderRadius.vertical(top: Radius.circular(borderRadius))
        : BorderRadius.circular(borderRadius);

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: finalOpacity),
        borderRadius: border,
        border: useBorder
            ? Border.all(
                color: ThemeManager.current.iconColor.withValues(alpha: 0.2),
              )
            : null,
      ),
      child: child,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: border,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  offset: const Offset(0, 5),
                  blurRadius: elevation * 1.5,
                  spreadRadius: elevation * 0.5,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: border,
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: finalBlur, sigmaY: finalBlur),
          child: content,
        ),
      ),
    );
  }
}
