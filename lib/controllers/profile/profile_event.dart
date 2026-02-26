import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final int userId;

  const ProfileLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
