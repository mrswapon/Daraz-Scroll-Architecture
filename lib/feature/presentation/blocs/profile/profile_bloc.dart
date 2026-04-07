import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/user/get_user_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserUseCase _getUserUseCase;

  ProfileBloc({required GetUserUseCase getUserUseCase})
      : _getUserUseCase = getUserUseCase,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _getUserUseCase(GetUserParams(userId: event.userId));
    
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }
}
