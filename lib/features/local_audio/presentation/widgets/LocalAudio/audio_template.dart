import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class AudioTemplate extends StatefulWidget {
  const AudioTemplate({super.key, required this.audioEntity});

  final AudioEntity audioEntity;

  @override
  State<AudioTemplate> createState() => _AudioTemplateState();
}

class _AudioTemplateState extends State<AudioTemplate> {
  Uint8List? cover;
  final double size = 50;

  @override
  void initState() {
    super.initState();
    cover = widget.audioEntity.cover;
    if (cover == null) getCover();
  }

  Future<void> getCover() async {
    cover = await AudioUtil.getCover(
      widget.audioEntity.id,
      coverSize: CoverSize.thumbnail,
    );
    if (!mounted) return;
    if (cover != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle infoTextStyle = TextStyle(
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontSize: 13,
    );
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        spacing: 10,
        children: [
          // --- تصویر ---
          SizedBox(
            width: size,
            height: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: cover != null
                    ? MemoryImage(cover!)
                    : const AssetImage('assets/logo.png') as ImageProvider,
                width: size,
                height: size,
                fit: cover != null ? BoxFit.cover : BoxFit.scaleDown,
                filterQuality: FilterQuality.high,
                errorBuilder: (ctx, error, stack) => Image.asset(
                  'assets/logo.png',
                  width: size,
                  height: size,
                  fit: BoxFit.scaleDown,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),

          // --- متن‌ها ---
          Expanded(
            child: Column(
              spacing: 2,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.audioEntity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.audioEntity.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: infoTextStyle,
                ),
              ],
            ),
          ),
          Text(
            AudioUtil.convertTime(widget.audioEntity.duration),
            style: infoTextStyle,
          ),
        ],
      ),
    );
  }
}
