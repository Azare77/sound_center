import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/podcast/presentation/widgets/player/description.dart'
    as desc_widget;
import 'package:sound_center/generated/l10n.dart';

void main() {
  testWidgets('Description dialog shows OK button and content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) =>
                  desc_widget.Description(description: '<p>Hello</p>'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('OK'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
  });
}
