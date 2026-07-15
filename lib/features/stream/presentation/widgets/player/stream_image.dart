import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class StreamImage extends StatefulWidget {
  const StreamImage({super.key, required this.id, this.cover, this.coverUrl});

  final int id;
  final Uint8List? cover;
  final String? coverUrl;

  @override
  State<StreamImage> createState() => _StreamImageState();
}

class _StreamImageState extends State<StreamImage> {
  Uint8List? img;

  @override
  void initState() {
    super.initState();
    img = widget.cover;
    if (img == null) loadImage();
  }

  void loadImage() async {
    img = await AudioUtil.getCover(widget.id, coverSize: CoverSize.banner);
    if (img != null && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.coverUrl != null
            ? NetworkCacheImage(url: widget.coverUrl)
            : Image(
                image: img != null
                    ? MemoryImage(img!)
                    : const AssetImage('assets/default-cover.png')
                          as ImageProvider,
                fit: img != null ? BoxFit.cover : BoxFit.scaleDown,
                filterQuality: FilterQuality.high,
                errorBuilder: (ctx, error, stack) => Image.asset(
                  'assets/default-cover.png',
                  fit: BoxFit.scaleDown,
                  filterQuality: FilterQuality.high,
                ),
              ),
      ),
    );
  }
}
