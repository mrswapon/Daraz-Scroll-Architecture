import '../../../core/error/failure.dart';
import '../../../core/usecase/usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login({
    required String username,
    required String password,
  });
}
