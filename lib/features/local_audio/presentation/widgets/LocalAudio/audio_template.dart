import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/core/util/audio/audio_util.dart';
import 'package:sound_center/features/local_audio/domain/entities/audio.dart';

class AudioTemplate extends StatefulWidget {
  const AudioTemplate({
    super.key,
    required this.audioEntity,
    this.isMultiple = false,
    this.isSelected = false,
    this.onChanged,
  });

  final AudioEntity audioEntity;
  final bool isMultiple;
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;

  @override
  State<AudioTemplate> createState() => _AudioTemplateState();
}

class _AudioTemplateState extends State<AudioTemplate> {
  Uint8List? cover;
  final double size = 50;
  final double spacing = 10;

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
      height: LIST_ITEM_HEIGHT,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.isMultiple
                ? Padding(
                    padding: EdgeInsetsDirectional.only(end: spacing),
                    child: Checkbox(
                      value: widget.isSelected,
                      onChanged: widget.onChanged,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // --- تصویر ---
          SizedBox(
            width: size,
            height: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                key: ValueKey(widget.audioEntity.id),
                image: cover != null
                    ? MemoryImage(cover!)
                    : const AssetImage('assets/default-cover.png')
                          as ImageProvider,
                width: size,
                height: size,
                fit: cover != null ? BoxFit.cover : BoxFit.scaleDown,
                filterQuality: FilterQuality.high,
                errorBuilder: (ctx, error, stack) => Image.asset(
                  'assets/default-cover.png',
                  width: size,
                  height: size,
                  fit: BoxFit.scaleDown,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),
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
          SizedBox(width: spacing),
          Text(
            AudioUtil.convertTime(widget.audioEntity.duration),
            style: infoTextStyle,
          ),
        ],
      ),
    );
  }
}
