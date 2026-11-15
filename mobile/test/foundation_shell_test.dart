import 'dart:convert';

import 'package:elora_mobile/core/config.dart';
import 'package:elora_mobile/core/elora_shell.dart';
import 'package:elora_mobile/core/network/api_client.dart';
import 'package:elora_mobile/core/providers.dart';
import 'package:elora_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _VerifiedUser extends Fake implements User {
  @override
  bool get emailVerified => true;
}

void main() {
  testWidgets('all five module routes share navigation and garden access', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWithValue(_config),
          authStateProvider.overrideWith(
            (ref) => Stream.value(_VerifiedUser()),
          ),
          profileProvider.overrideWith((ref) async => null),
        ],
        child: const EloraApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);
    expect(find.byType(EloraBottomNavigation), findsOneWidget);

    const tabs = {
      'Quality': EloraModule.quality,
      'Farming': EloraModule.farming,
      'Scan': EloraModule.cropHealth,
      'Chat': EloraModule.assistant,
      'Community': EloraModule.community,
    };
    final navigation = find.byType(EloraBottomNavigation);
    for (final MapEntry(key: label, value: module) in tabs.entries) {
      await tester.tap(
        find.descendant(of: navigation, matching: find.text(label)),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<EloraBottomNavigation>(navigation).selected, module);
    }

    await tester.tap(find.byTooltip('My garden'));
    await tester.pumpAndSettle();
    expect(find.text('My garden'), findsOneWidget);
    expect(tester.widget<EloraBottomNavigation>(navigation).selected, isNull);
  });

  testWidgets('profile validates and saves the display name', (tester) async {
    var name = 'Garden Tester';
    final api = EloraApiClient(
      baseUrl: _config.apiUrl,
      token: (_) async => 'test-token',
      client: MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/v1/profile');
        name = (jsonDecode(request.body) as Map)['display_name'] as String;
        return http.Response('{}', 200);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          configProvider.overrideWithValue(_config),
          authStateProvider.overrideWith(
            (ref) => Stream.value(_VerifiedUser()),
          ),
          profileProvider.overrideWith(
            (ref) async => {
              'id': 'test-profile',
              'display_name': name,
              'email': 'grower@example.com',
            },
          ),
          plantsProvider.overrideWith((ref) async => []),
          apiProvider.overrideWithValue(api),
        ],
        child: const EloraApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('My profile'));
    await tester.pumpAndSettle();
    expect(find.text('grower@example.com'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsOneWidget);
    expect(name, 'Garden Tester');

    await tester.enterText(find.byType(TextFormField), '  New Name  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(name, 'New Name');
    expect(find.text('Profile saved.'), findsOneWidget);
  });
}

const _config = AppConfig(
  apiUrl: 'https://example.com',
  firebaseApiKey: 'configured',
  firebaseAppId: 'configured',
  firebaseSenderId: 'configured',
  firebaseProjectId: 'configured',
);
