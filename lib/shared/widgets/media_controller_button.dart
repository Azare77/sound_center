import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MediaControllerButton extends StatelessWidget {
  const MediaControllerButton({
    super.key,
    required this.svg,
    this.onPressed,
    this.color = Colors.white,
  });

  final String svg;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          svg,
          width: 30,
          height: 30,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
