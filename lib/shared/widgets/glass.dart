import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:sound_center/shared/theme/themes.dart';

class Glass extends StatelessWidget {
  const Glass({
    super.key,
    this.radius = 0.0,
    required this.color,
    required this.child,
    this.blur,
    this.opacity,
    this.elevation = 0.0,
    this.useBorder = true,
  });

  final double radius;
  final Color color;
  final double? blur;
  final double? opacity;
  final double elevation;
  final Widget child;
  final bool useBorder;

  @override
  Widget build(BuildContext context) {
    final finalOpacity = opacity ?? ThemeManager.current.opacity;
    final finalBlur = blur ?? ThemeManager.current.blur;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  offset: Offset(0, 5),
                  blurRadius: elevation * 1.5,
                  spreadRadius: elevation * 0.5,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: finalBlur, sigmaY: finalBlur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: finalOpacity),
              borderRadius: BorderRadius.circular(radius),
              border: useBorder
                  ? Border.all(
                      color: ThemeManager.current.iconColor.withValues(
                        alpha: 0.2,
                      ),
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
