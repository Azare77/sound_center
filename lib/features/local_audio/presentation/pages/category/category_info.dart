import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:sound_center/core/constants/constants.dart';
import 'package:sound_center/shared/widgets/scrolling_text.dart';

class CategoryInfo extends StatelessWidget {
  const CategoryInfo({super.key, required this.title, this.image});

  final String title;
  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets edgeInsets = EdgeInsets.fromViewPadding(
      WidgetsBinding.instance.platformDispatcher.views.first.padding,
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double appBarHeight = constraints.maxHeight;
        double toolbar = kToolbarHeight + edgeInsets.top;
        double visibleHeight = appBarHeight - toolbar;
        double totalExpandableRange = EXPANDED_HEIGHT - toolbar;
        double rawRatio = visibleHeight / totalExpandableRange;
        double t = rawRatio.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: FlexibleSpaceBar(
            title: Padding(
              padding: EdgeInsets.only(top: toolbar),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  ScrollingText(title, style: TextStyle(color: Colors.white)),
                  if (t == 1) Row(spacing: 5, children: []),
                ],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: title,
                  child: Image(
                    image: image != null
                        ? MemoryImage(image!)
                        : const AssetImage('assets/default-cover.png')
                              as ImageProvider,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (ctx, error, stack) => Image.asset(
                      'assets/default-cover.png',
                      fit: BoxFit.scaleDown,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: t * 0.6,
                  duration: Duration(milliseconds: 500),
                  child: Container(color: Colors.black),
                ),
              ],
            ),
            titlePadding: EdgeInsetsGeometry.symmetric(
              horizontal: 5,
              vertical: 5,
            ),
            expandedTitleScale: 1,
          ),
        );
      },
    );
  }
}
