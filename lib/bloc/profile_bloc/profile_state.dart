import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class ProfileInitial extends ProfileState {}

// Loading states
class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileAvatarUploading extends ProfileState {}

// Success states
class ProfileLoaded extends ProfileState {
  final UserModel user;

  ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final UserModel user;
  final String message;

  ProfileUpdated({
    required this.user,
    this.message = 'Profile updated successfully',
  });

  @override
  List<Object?> get props => [user, message];
}

class ProfileAvatarUpdated extends ProfileState {
  final UserModel user;
  final String message;

  ProfileAvatarUpdated({
    required this.user,
    this.message = 'Avatar updated successfully',
  });

  @override
  List<Object?> get props => [user, message];
}

// Error states
class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateError extends ProfileState {
  final String message;

  ProfileUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileAvatarUploadError extends ProfileState {
  final String message;

  ProfileAvatarUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Network error state
class ProfileNetworkError extends ProfileState {
  final String message;

  ProfileNetworkError({
    this.message =
        'Network connection error. Please check your internet connection.',
  });

  @override
  List<Object?> get props => [message];
}

// Validation error state
class ProfileValidationError extends ProfileState {
  final Map<String, String> errors;

  ProfileValidationError({required this.errors});

  @override
  List<Object?> get props => [errors];
}
