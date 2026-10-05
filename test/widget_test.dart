import 'package:digital_pet/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the pet care screen', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());

    expect(find.text('Digital Pet'), findsOneWidget);
    expect(find.text('Happiness'), findsOneWidget);
    expect(find.text('Hunger'), findsOneWidget);
    expect(find.text('Energy'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Feed'), 400, scrollable: find.byType(Scrollable).first);
    expect(find.text('Feed'), findsOneWidget);
  });

  testWidgets('feeding updates the hunger meter', (tester) async {
    await tester.pumpWidget(const DigitalPetApp());
    await tester.scrollUntilVisible(find.text('Feed'), 400, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Feed'));
    await tester.pump();

    expect(find.text('40 / 100'), findsOneWidget);
  });
}
