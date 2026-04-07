import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteDataSource {
  static const String _baseUrl = 'https://fakestoreapi.com';
  final http.Client _client;

  RemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String endpoint) async {
    final response = await _client.get(Uri.parse('$_baseUrl$endpoint'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw RemoteDataSourceException(
      'GET $endpoint failed with status code: ${response.statusCode}',
    );
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
    throw RemoteDataSourceException(
      'POST $endpoint failed with status code: ${response.statusCode}',
    );
  }

  void dispose() {
    _client.close();
  }
}

class RemoteDataSourceException implements Exception {
  final String message;
  const RemoteDataSourceException(this.message);

  @override
  String toString() => 'RemoteDataSourceException: $message';
}
