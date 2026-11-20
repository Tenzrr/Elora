import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:elora_mobile/core/network/api_client.dart';
import 'package:elora_mobile/core/providers.dart';
import 'package:elora_mobile/features/crop_health/scan_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'multipart auth, retained selection, same-key retry, and new-photo key',
    () async {
      final keys = <String>[];
      final api = EloraApiClient(
        baseUrl: 'https://example.test',
        token: (_) async => 'firebase-token',
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer firebase-token');
          if (request.method == 'POST') {
            expect(
              request.headers['Content-Type'],
              startsWith('multipart/form-data; boundary='),
            );
            expect(request.body, contains('name="crop_slug"\r\n\r\ntomato'));
            expect(request.body, contains('name="task"\r\n\r\ndisease'));
            keys.add(request.headers['Idempotency-Key']!);
            if (keys.length == 1) throw http.ClientException('offline');
            return http.Response('{"scan_id":"job-1"}', 202);
          }
          expect(request.url.path, '/api/v1/scans/job-1');
          return http.Response(
            '{"status":"failed","result":null,"error":{"code":"MODEL_UNAVAILABLE"}}',
            200,
          );
        }),
      );
      addTearDown(api.close);
      final container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(api),
          authStateProvider.overrideWith((ref) => const Stream<User?>.empty()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(scanProvider.notifier);
      final bytes = Uint8List.fromList([1, 2, 3]);
      controller.select(bytes);
      await controller.submit();
      expect(container.read(scanProvider).error, 'NETWORK_UNAVAILABLE');
      expect(container.read(scanProvider).bytes, same(bytes));
      await controller.submit();
      expect(keys[0], keys[1]);
      expect(
        keys[0],
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(container.read(scanProvider).status, 'failed');
      expect(container.read(scanProvider).error, 'MODEL_UNAVAILABLE');
      controller.select(Uint8List.fromList([4]));
      expect(container.read(scanProvider).operationId, isNot(keys[0]));
      expect(container.read(scanProvider).scanId, isNull);
    },
  );

  test(
    'authentication change drops photo and ignores an old in-flight response',
    () async {
      final auth = StreamController<User?>();
      addTearDown(auth.close);
      final response = Completer<http.Response>();
      final api = EloraApiClient(
        baseUrl: 'https://example.test',
        token: (_) async => 'token',
        client: MockClient((_) => response.future),
      );
      addTearDown(api.close);
      final container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(api),
          authStateProvider.overrideWith((ref) => auth.stream),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(scanProvider, (_, _) {});
      addTearDown(subscription.close);
      auth.add(_User());
      await Future<void>.delayed(Duration.zero);
      final controller = container.read(scanProvider.notifier);
      controller.select(Uint8List.fromList([1]));
      final pending = controller.submit();
      await Future<void>.delayed(Duration.zero);
      auth.add(_User()); // A token refresh for the same UID must preserve work.
      await Future<void>.delayed(Duration.zero);
      expect(container.read(scanProvider).bytes, isNotNull);
      auth.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(scanProvider).bytes, isNull);
      response.complete(
        http.Response(jsonEncode({'scan_id': 'old-account-job'}), 202),
      );
      await pending;
      expect(container.read(scanProvider).scanId, isNull);
    },
  );

  testWidgets('polls with bounded delay, pauses in background, resumes reads', (
    tester,
  ) async {
    var reads = 0;
    final api = EloraApiClient(
      baseUrl: 'https://example.test',
      token: (_) async => 'token',
      client: MockClient((request) async {
        if (request.method == 'POST') {
          return http.Response('{"scan_id":"job"}', 202);
        }
        reads++;
        return http.Response(
          '{"status":"${reads >= 4 ? 'failed' : 'queued'}","error":{"code":"MODEL_UNAVAILABLE"}}',
          200,
        );
      }),
    );
    addTearDown(api.close);
    final container = ProviderContainer(
      overrides: [
        apiProvider.overrideWithValue(api),
        authStateProvider.overrideWith((ref) => const Stream<User?>.empty()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(scanProvider.notifier);
    controller.select(Uint8List.fromList([1]));
    final submitted = controller.submit();
    await tester.pump();
    await submitted;
    expect(reads, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(reads, 2);
    controller.foreground(false);
    await tester.pump(const Duration(seconds: 20));
    expect(reads, 2);
    controller.foreground(true);
    await tester.pump();
    expect(reads, 3);
    await tester.pump(const Duration(seconds: 8));
    expect(reads, 4);
    await tester.pump(const Duration(seconds: 20));
    expect(reads, 4);
  });
}

class _User extends Fake implements User {
  @override
  String get uid => 'provider-fixture-user';
}
