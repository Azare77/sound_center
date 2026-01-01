import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_center/features/podcast/presentation/widgets/network_image.dart';

void main() {
  testWidgets('NetworkCacheImage shows fallback when url is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: NetworkCacheImage(url: null, size: 40)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    final Image imageWidget = tester.widget(imageFinder);
    expect(imageWidget.image, isA<AssetImage>());
    final asset = imageWidget.image as AssetImage;
    expect(asset.assetName, equals('assets/default-cover.png'));
  });
}
