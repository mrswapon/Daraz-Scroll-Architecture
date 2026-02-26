import '../models/user_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository({required ApiService apiService}) : _apiService = apiService;

  Future<UserModel> getUser(int userId) async {
    final data = await _apiService.get('/users/$userId');
    return UserModel.fromJson(data);
  }
}
