import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('all demo pages render at tablet size', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ExampleApp());
    expect(find.text('Road Trip Mix'), findsOneWidget);

    await tester.tap(find.text('Sprint'));
    await tester.pumpAndSettle();
    expect(find.text('Sprint 42 · Backlog'), findsOneWidget);

    await tester.tap(find.text('Playground'));
    await tester.pumpAndSettle();
    expect(find.text('Same Tree'), findsOneWidget);
  });
}
