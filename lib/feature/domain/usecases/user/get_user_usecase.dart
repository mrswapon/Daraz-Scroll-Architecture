import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class GetUserParams extends Equatable {
  final int userId;

  const GetUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetUserUseCase extends UseCase<User, GetUserParams> {
  final UserRepository _userRepository;

  GetUserUseCase({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, User>> call(GetUserParams params) async {
    return await _userRepository.getUser(params.userId);
  }
}
