part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String userType;
  final String? phone;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.userType,
    this.phone,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        passwordConfirmation,
        userType,
        phone,
      ];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String email;
  final String password;
  final String passwordConfirmation;

  const AuthResetPasswordRequested({
    required this.token,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [token, email, password, passwordConfirmation];
}

class AuthUserRefreshRequested extends AuthEvent {}

class AuthTokenRefreshRequested extends AuthEvent {}

class AuthSessionExpired extends AuthEvent {}

class AuthNetworkError extends AuthEvent {
  final String message;

  const AuthNetworkError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthSwitchToContractorMode extends AuthEvent {}
