import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sound_center/shared/theme/themes.dart';

class MediaControllerButton extends StatelessWidget {
  const MediaControllerButton({
    super.key,
    required this.svg,
    this.onPressed,
    this.color,
    this.width = 60,
    this.height = 60,
  });

  final String svg;
  final VoidCallback? onPressed;
  final Color? color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          svg,
          width: width / 2,
          height: height / 2,
          colorFilter: ColorFilter.mode(
            color ?? AppTheme.current.svgColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
