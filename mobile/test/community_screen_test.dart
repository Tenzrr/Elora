import 'dart:convert';

import 'package:elora_mobile/core/network/api_client.dart';
import 'package:elora_mobile/core/providers.dart';
import 'package:elora_mobile/core/theme/app_theme.dart';
import 'package:elora_mobile/features/community/community_screen.dart';
import 'package:elora_mobile/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('community loads private posts and shows privacy notice', (
    tester,
  ) async {
    final api = EloraApiClient(
      baseUrl: 'https://example.com',
      token: (_) async => 'test-token',
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/community/posts');

        return http.Response(
          jsonEncode({
            'items': [
              {
                'id': '11111111-1111-4111-8111-111111111111',
                'user_id': 'alice-id',
                'text': 'My tomato plant is growing well.',
                'published_at': null,
                'created_at': '2026-11-24T09:00:00Z',
                'updated_at': '2026-11-24T09:00:00Z',
              }
            ],
            'next_cursor': null,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiProvider.overrideWithValue(api),
          authStateProvider.overrideWith(
            (ref) => Stream<User?>.value(null),
          ),
          profileProvider.overrideWith(
            (ref) async => {'display_name': 'Alice'},
          ),
        ],
        child: MaterialApp(
          theme: EloraTheme.light(),
          localizationsDelegates:
              AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CommunityScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My posts'), findsOneWidget);
    expect(find.text('My tomato plant is growing well.'), findsOneWidget);
    expect(find.text('Private draft'), findsOneWidget);
    expect(
      find.textContaining('Only you can see saved drafts'),
      findsOneWidget,
    );
  });

  testWidgets('post composer requires preview before saving a draft', (
    tester,
  ) async {
    var postCreated = false;

    final api = EloraApiClient(
      baseUrl: 'https://example.com',
      token: (_) async => 'test-token',
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({'items': [], 'next_cursor': null}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/community/posts');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['text'], 'My first community draft');

        postCreated = true;

        return http.Response(
          jsonEncode({
            'id': '22222222-2222-4222-8222-222222222222',
            'user_id': 'alice-id',
            'text': body['text'],
            'published_at': null,
            'created_at': '2026-11-24T10:00:00Z',
            'updated_at': '2026-11-24T10:00:00Z',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiProvider.overrideWithValue(api),
          authStateProvider.overrideWith(
            (ref) => Stream<User?>.value(null),
          ),
          profileProvider.overrideWith(
            (ref) async => {'display_name': 'Alice'},
          ),
        ],
        child: MaterialApp(
          theme: EloraTheme.light(),
          localizationsDelegates:
              AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CommunityScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Create post'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'My first community draft',
    );
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(
      FilledButton,
      'Save private draft',
    );

    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
    expect(postCreated, isFalse);

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('My first community draft'), findsWidgets);
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(postCreated, isTrue);
    expect(find.text('Your draft was saved.'), findsOneWidget);
    expect(find.text('Private draft'), findsOneWidget);
  });
}
