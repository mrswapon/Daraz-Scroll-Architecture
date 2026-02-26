import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({required ApiService apiService}) : _apiService = apiService;

  //=======================> Authenticates with FakeStore API. Returns a JWT token string. <================================
  Future<String> login(String username, String password) async {
    final data = await _apiService.post('/auth/login', {
      'username': username,
      'password': password,
    });
    return data['token'] as String;
  }
}
