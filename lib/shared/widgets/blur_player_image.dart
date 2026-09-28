import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/services/just_audio_service.dart';
import 'package:sound_center/features/settings/data/settings_repository_imp.dart';
import 'package:sound_center/features/settings/domain/settings_repository.dart';
import 'package:sound_center/features/stream/presentation/widgets/player/stream_image.dart';
import 'package:sound_center/shared/theme/themes.dart';
import 'package:sound_center/shared/widgets/glass.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class BlurPlayerImage extends StatelessWidget {
  const BlurPlayerImage({super.key, required this.img, required this.source});

  final dynamic img;
  final AudioSource source;

  @override
  Widget build(BuildContext context) {
    final coverType = SettingsRepositoryImp().getPlayerStyle();
    if (coverType == PlayerStyle.solid) {
      return Container(
        width: MediaQuery.widthOf(context),
        height: MediaQuery.heightOf(context),
        color: ThemeManager.current.scaffoldBackground,
      );
    }
    Color backgroundColor = ThemeManager.current.scaffoldBackground;
    if (coverType == PlayerStyle.glassy) {
      final opacity = min(0.3, ThemeManager.current.opacity);
      final blur = max(1.0, ThemeManager.current.blur);
      return Glass(
        borderRadius: 0,
        color: backgroundColor,
        opacity: opacity,
        blur: blur,
        useBorder: false,
        child: SizedBox.expand(),
      );
    } else {
      return SizedBox(
        width: MediaQuery.widthOf(context),
        height: MediaQuery.heightOf(context),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: backgroundColor),
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Transform.scale(scale: 1.1, child: image()),
              ),
              // Dark overlay
              ColoredBox(color: backgroundColor.withValues(alpha: 0.2)),
            ],
          ),
        ),
      );
    }
  }

  Widget image() {
    switch (source) {
      case AudioSource.local:
        return Image(
          image: img != null
              ? MemoryImage(img as Uint8List)
              : const AssetImage('assets/default-cover.png'),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (ctx, error, stack) => Image.asset(
            'assets/default-cover.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        );
      case AudioSource.podcast || AudioSource.cloud:
        return NetworkCacheImage(url: img, size: null, fit: BoxFit.cover);
      case AudioSource.stream:
        return StreamImage(id: -1, coverUrl: img);
    }
  }
}
