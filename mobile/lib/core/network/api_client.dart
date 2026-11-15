import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.code, {this.status});
  final String code;
  final int? status;
}

class EloraApiClient {
  EloraApiClient({
    required this.baseUrl,
    required this.token,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final Future<String?> Function(bool forceRefresh) token;
  final http.Client _client;

  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    int? revision,
  }) async {
    try {
      final uri = Uri.parse(
        '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/v1$path',
      );
      final request = http.Request(method, uri);
      final accessToken = await token(false);
      if (accessToken == null) {
        throw const ApiException('UNAUTHORIZED', status: 401);
      }
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        if (revision != null) 'If-Match': '"$revision"',
      });
      if (body != null) request.body = jsonEncode(body);
      var response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 20)),
      ).timeout(const Duration(seconds: 20));
      // Only replay reads. Unknown-outcome mutations must never be blindly retried.
      if (response.statusCode == 401 && method == 'GET') {
        final refreshed = await token(true);
        if (refreshed != null) {
          response = await _client
              .get(uri, headers: {'Authorization': 'Bearer $refreshed'})
              .timeout(const Duration(seconds: 20));
        }
      }
      dynamic data;
      try {
        data = response.body.isEmpty ? null : jsonDecode(response.body);
      } on FormatException {
        throw ApiException('INVALID_RESPONSE', status: response.statusCode);
      }
      if (response.statusCode >= 400) {
        throw ApiException(
          data is Map
              ? (data['error']?['code'] as String? ?? 'REQUEST_FAILED')
              : 'REQUEST_FAILED',
          status: response.statusCode,
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException('TIMEOUT');
    } on http.ClientException {
      throw const ApiException('NETWORK_UNAVAILABLE');
    }
  }

  void close() => _client.close();
}
