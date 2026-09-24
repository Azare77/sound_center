import 'package:material_ui/material_ui.dart';
import 'package:sound_center/shared/widgets/network_image.dart';

class TrackHeaderImage extends StatelessWidget {
  const TrackHeaderImage({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: NetworkCacheImage(
          url: url,
          size: null,
          fit: url != null ? BoxFit.cover : BoxFit.scaleDown,
        ),
      ),
    );
  }
}
