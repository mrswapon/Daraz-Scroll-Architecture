import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUser(int userId);
}
