import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, String>> login({
    required String username,
    required String password,
  }) async {
    try {
      final data = await _remoteDataSource.post('/auth/login', {
        'username': username,
        'password': password,
      });
      final token = data['token'] as String;
      return Either.right(token);
    } on RemoteDataSourceException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
