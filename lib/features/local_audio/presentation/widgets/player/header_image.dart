import 'dart:typed_data';

import 'package:flutter/material.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key, this.img});

  final Uint8List? img;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: img != null
              ? MemoryImage(img!)
              : const AssetImage('assets/logo.png') as ImageProvider,
          fit: img != null ? BoxFit.cover : BoxFit.scaleDown,
          filterQuality: FilterQuality.high,
          errorBuilder: (ctx, error, stack) => Image.asset(
            'assets/logo.png',
            fit: BoxFit.scaleDown,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
