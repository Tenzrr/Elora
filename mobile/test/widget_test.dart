import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elora_mobile/core/providers.dart';
import 'package:elora_mobile/main.dart';

void main() {
  for (final locale in ['en', 'si', 'ta']) {
    testWidgets('unconfigured startup is usable in $locale without Firebase', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [initialLocaleProvider.overrideWithValue(Locale(locale))],
          child: const EloraApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Elora'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
