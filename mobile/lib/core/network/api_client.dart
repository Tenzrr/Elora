import 'package:http/http.dart' as http;

class GardenApiClient {
  GardenApiClient({http.Client? client, required this.baseUrl})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<http.Response> getHealth() => _client.get(Uri.parse('$baseUrl/health'));
}
