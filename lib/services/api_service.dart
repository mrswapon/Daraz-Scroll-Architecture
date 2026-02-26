import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String endpoint) async {
    final response = await _client.get(Uri.parse('$_baseUrl$endpoint'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException('GET $endpoint failed: ${response.statusCode}');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw ApiException('POST $endpoint failed: ${response.statusCode}');
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
