import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;

  ProfileBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _userRepository.getUser(event.userId);
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
