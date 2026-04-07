import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_dto.dart';
import '../sources/remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource _remoteDataSource;

  UserRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, User>> getUser(int userId) async {
    try {
      final data = await _remoteDataSource.get('/users/$userId');
      final userDto = UserDto.fromJson(data);
      return Either.right(userDto.toEntity());
    } on RemoteDataSourceException catch (e) {
      return Either.left(ServerFailure(e.message));
    } catch (e) {
      return Either.left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
