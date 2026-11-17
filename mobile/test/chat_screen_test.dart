import 'dart:convert';

import 'package:elora_mobile/core/network/api_client.dart';
import 'package:elora_mobile/core/providers.dart';
import 'package:elora_mobile/core/theme/app_theme.dart';
import 'package:elora_mobile/features/agricultural_agent/screens/chat_screen.dart';
import 'package:elora_mobile/features/agricultural_agent/widgets/chat_bubbles.dart';
import 'package:elora_mobile/features/agricultural_agent/widgets/chat_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('chat screen renders header and initial welcome bubble', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: EloraTheme.light(),
          home: const Scaffold(body: ChatScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Garden assistant'), findsOneWidget);
    expect(find.text('• AI powered • Here to help you grow'), findsOneWidget);
    expect(find.text('Today, 9:41 AM'), findsOneWidget);
    expect(find.byType(AssistantChatBubble), findsOneWidget);
    expect(
      find.text('Hi there! What is growing in your garden today?'),
      findsOneWidget,
    );
    expect(find.byType(ChatInputBar), findsOneWidget);
    expect(find.text('Ask your garden assistant...'), findsOneWidget);
    expect(find.text('A little AI help for a happier garden.'), findsOneWidget);
  });

  testWidgets('sending message adds user bubble and receives assistant reply', (
    tester,
  ) async {
    final mockClient = MockClient((request) async {
      expect(request.method, 'POST');
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload['message'], 'My tomato leaves are yellow');

      return http.Response(
        jsonEncode({
          'thread_id': 'thread12345',
          'response': 'Check soil moisture before watering.',
          'tools_executed': [],
        }),
        200,
      );
    });

    final api = EloraApiClient(
      baseUrl: 'https://example.com',
      token: (_) async => 'token123',
      client: mockClient,
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiProvider.overrideWithValue(api),
        ],
        child: MaterialApp(
          theme: EloraTheme.light(),
          home: const Scaffold(body: ChatScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField), 'My tomato leaves are yellow');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();

    expect(find.text('My tomato leaves are yellow'), findsOneWidget);
    expect(find.byType(UserChatBubble), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Check soil moisture before watering.'), findsOneWidget);
    expect(find.byType(AssistantChatBubble), findsNWidgets(2));
  });

  testWidgets('tapping camera attachment shows guidance snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: EloraTheme.light(),
          home: const Scaffold(body: ChatScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Attach photo'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'To scan a plant leaf for disease diagnosis, use the Scan tab in the bottom bar.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('server error displays inline notification banner', (
    tester,
  ) async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({'error': {'code': 'SERVICE_UNAVAILABLE'}}),
        503,
      );
    });

    final api = EloraApiClient(
      baseUrl: 'https://example.com',
      token: (_) async => 'token123',
      client: mockClient,
    );
    addTearDown(api.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiProvider.overrideWithValue(api),
        ],
        child: MaterialApp(
          theme: EloraTheme.light(),
          home: const Scaffold(body: ChatScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Failing message test');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to reach assistant. Please check your connection.'),
      findsOneWidget,
    );
  });
}
