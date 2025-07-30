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
        child: img != null
            ? Image.memory(
                img!,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              )
            : Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
      ),
    );
  }
}
