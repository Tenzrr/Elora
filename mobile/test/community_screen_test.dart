import 'dart:async';
import 'dart:convert';

import 'package:elora_mobile/core/network/api_client.dart';
import 'package:elora_mobile/core/providers.dart';
import 'package:elora_mobile/features/community/community_provider.dart';
import 'package:elora_mobile/core/theme/app_theme.dart';
import 'package:elora_mobile/features/community/community_screen.dart';
import 'package:elora_mobile/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _TestUser implements User {
  _TestUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
              },
            ],
            'next_cursor': null,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(api.close);
    final authEvents = StreamController<User?>.broadcast();
    final authReady = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        apiProvider.overrideWithValue(api),
        authStateProvider.overrideWith((ref) => authEvents.stream),
        profileProvider.overrideWith((ref) async => {'display_name': 'Alice'}),
      ],
    );

    final authSubscription = container.listen(authStateProvider, (_, next) {
      if (next.asData?.value?.uid == 'account-1' && !authReady.isCompleted) {
        authReady.complete();
      }
    });

    addTearDown(() async {
      authSubscription.close();
      container.dispose();
      await authEvents.close();
    });

    authEvents.add(_TestUser('account-1'));

    await authReady.future;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: EloraTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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
            (ref) => Stream<User?>.value(_TestUser('account-1')),
          ),
          profileProvider.overrideWith(
            (ref) async => {'display_name': 'Alice'},
          ),
        ],
        child: MaterialApp(
          theme: EloraTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CommunityScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Create post'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'My first community draft');
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(FilledButton, 'Save private draft');

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
  test(
    'discards delayed Account 1 response after switching to Account 2',
    () async {
      final authEvents = StreamController<User?>.broadcast();

      final account1Ready = Completer<void>();
      final account2Ready = Completer<void>();
      final requestStarted = Completer<void>();
      final delayedResponse = Completer<http.Response>();

      final api = EloraApiClient(
        baseUrl: 'https://example.com',
        token: (_) async => 'test-token',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          requestStarted.complete();
          return delayedResponse.future;
        }),
      );

      final container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(api),
          authStateProvider.overrideWith((ref) => authEvents.stream),
        ],
      );

      final authSubscription = container.listen(authStateProvider, (_, next) {
        final uid = next.asData?.value?.uid;

        if (uid == 'account-1' && !account1Ready.isCompleted) {
          account1Ready.complete();
        }

        if (uid == 'account-2' && !account2Ready.isCompleted) {
          account2Ready.complete();
        }
      });

      final communitySubscription = container.listen(
        communityProvider,
        (_, next) {},
      );

      addTearDown(() {
        authSubscription.close();
        communitySubscription.close();
        container.dispose();
        authEvents.close();
        api.close();
      });

      authEvents.add(_TestUser('account-1'));
      await account1Ready.future;
      await Future<void>.delayed(Duration.zero);

      final loadFuture = container
          .read(communityProvider.notifier)
          .loadPosts(refresh: true);

      await requestStarted.future;

      authEvents.add(_TestUser('account-2'));
      await account2Ready.future;
      await Future<void>.delayed(Duration.zero);

      delayedResponse.complete(
        http.Response(
          jsonEncode({
            'items': [
              {
                'id': '11111111-1111-4111-8111-111111111111',
                'user_id': 'account-1-db-id',
                'text': 'Account 1 private draft',
                'published_at': null,
                'created_at': '2026-11-27T09:00:00Z',
                'updated_at': '2026-11-27T09:00:00Z',
              },
            ],
            'next_cursor': null,
          }),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );

      await loadFuture;
      expect(container.read(communityProvider).posts, isEmpty);
      expect(container.read(communityProvider).hasLoaded, isFalse);
    },
  );
  test(
    'discards delayed Account 1 save response after switching to Account 2',
    () async {
      final authEvents = StreamController<User?>.broadcast();

      final account1Ready = Completer<void>();
      final account2Ready = Completer<void>();
      final requestStarted = Completer<void>();
      final delayedResponse = Completer<http.Response>();

      final api = EloraApiClient(
        baseUrl: 'https://example.com',
        token: (_) async => 'test-token',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/community/posts');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['text'], 'Account 1 private draft');

          requestStarted.complete();
          return delayedResponse.future;
        }),
      );

      final container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(api),
          authStateProvider.overrideWith((ref) => authEvents.stream),
        ],
      );

      final authSubscription = container.listen(authStateProvider, (_, next) {
        final uid = next.asData?.value?.uid;

        if (uid == 'account-1' && !account1Ready.isCompleted) {
          account1Ready.complete();
        }

        if (uid == 'account-2' && !account2Ready.isCompleted) {
          account2Ready.complete();
        }
      });

      final communitySubscription = container.listen(
        communityProvider,
        (_, next) {},
      );

      addTearDown(() async {
        authSubscription.close();
        communitySubscription.close();
        container.dispose();
        await authEvents.close();
        api.close();
      });

      authEvents.add(_TestUser('account-1'));
      await account1Ready.future;
      await Future<void>.delayed(Duration.zero);

      final saveFuture = container
          .read(communityProvider.notifier)
          .createPost('Account 1 private draft');

      await requestStarted.future;

      authEvents.add(_TestUser('account-2'));
      await account2Ready.future;
      await Future<void>.delayed(Duration.zero);

      delayedResponse.complete(
        http.Response(
          jsonEncode({
            'id': '33333333-3333-4333-8333-333333333333',
            'user_id': 'account-1-db-id',
            'text': 'Account 1 private draft',
            'published_at': null,
            'created_at': '2026-11-27T09:00:00Z',
            'updated_at': '2026-11-27T09:00:00Z',
          }),
          201,
          headers: {'content-type': 'application/json'},
        ),
      );

      final result = await saveFuture;

      expect(result, isFalse);
      expect(container.read(communityProvider).posts, isEmpty);
      expect(container.read(communityProvider).hasLoaded, isFalse);
    },
  );
}
