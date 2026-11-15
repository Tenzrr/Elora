import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:elora_mobile/core/network/api_client.dart';

void main() {
  test('reads refresh an expired token once', () async {
    var calls = 0;
    final api = EloraApiClient(
      baseUrl: 'https://example.test/',
      token: (force) async => force ? 'new' : 'old',
      client: MockClient((request) async {
        calls++;
        expect(request.url.path, '/api/v1/profile');
        if (calls == 1) {
          expect(request.headers['Authorization'], 'Bearer old');
          return http.Response(
            jsonEncode({
              'error': {'code': 'UNAUTHORIZED'},
            }),
            401,
          );
        }
        expect(request.headers['Authorization'], 'Bearer new');
        return http.Response('{}', 200);
      }),
    );
    await api.request('GET', '/profile');
    expect(calls, 2);
    api.close();
  });

  test('writes carry revision and are never automatically replayed', () async {
    var calls = 0;
    final api = EloraApiClient(
      baseUrl: 'https://example.test',
      token: (_) async => 'token',
      client: MockClient((request) async {
        calls++;
        expect(request.headers['If-Match'], '"4"');
        return http.Response(
          jsonEncode({
            'error': {'code': 'REVISION_CONFLICT'},
          }),
          409,
        );
      }),
    );
    await expectLater(
      api.request(
        'PATCH',
        '/plants/id',
        body: {'nickname': 'new'},
        revision: 4,
      ),
      throwsA(isA<ApiException>()),
    );
    expect(calls, 1);
    api.close();
  });

  test('non JSON server failures do not leak response text', () async {
    final api = EloraApiClient(
      baseUrl: 'https://example.test',
      token: (_) async => 'token',
      client: MockClient(
        (_) async => http.Response('<html>private error</html>', 502),
      ),
    );
    await expectLater(
      api.request('GET', '/profile'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'INVALID_RESPONSE'),
      ),
    );
    api.close();
  });
}
