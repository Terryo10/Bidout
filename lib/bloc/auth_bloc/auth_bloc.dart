import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/auth/register_request_model.dart';
import '../../models/auth/login_request_model.dart';
import '../../models/auth/google_auth_request_model.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repo/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthUserRefreshRequested>(_onAuthUserRefreshRequested);
    on<AuthTokenRefreshRequested>(_onAuthTokenRefreshRequested);
    on<AuthSwitchToContractorMode>(_onAuthSwitchToContractorMode);
    on<AuthSwitchToClientMode>(_onAuthSwitchToClientMode);

    // Auto-check authentication on app start
    add(AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          // Check if token needs refresh
          final shouldRefresh = await authRepository.shouldRefreshToken();
          if (shouldRefresh) {
            try {
              await authRepository.refreshUser();
              final refreshedUser = await authRepository.getCurrentUser();
              if (refreshedUser != null) {
                emit(AuthAuthenticated(user: refreshedUser));
              } else {
                emit(AuthUnauthenticated());
              }
            } catch (e) {
              // If refresh fails, use existing user data
              emit(AuthAuthenticated(user: user));
            }
          } else {
            emit(AuthAuthenticated(user: user));
          }
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // If any error occurs during auth check, consider user unauthenticated
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authRepository.login(
        LoginRequestModel(
          email: event.email,
          password: event.password,
        ),
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(AuthError(message: e.firstError));
      } else {
        emit(const AuthError(message: 'Login failed. Please try again.'));
      }
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authRepository.register(
        RegisterRequestModel(
          name: event.name,
          email: event.email,
          password: event.password,
          passwordConfirmation: event.passwordConfirmation,
          userType: event.userType,
          phone: event.phone,
        ),
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(AuthError(message: e.firstError));
      } else {
        emit(
            const AuthError(message: 'Registration failed. Please try again.'));
      }
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authRepository.googleSignIn(
        GoogleAuthRequestModel(
          idToken: event.idToken,
          userType: event.userType,
        ),
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(AuthError(message: e.firstError));
      } else {
        emit(const AuthError(
            message: 'Google Sign-In failed. Please try again.'));
      }
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails, we should consider user logged out locally
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authRepository.forgotPassword(event.email);
      emit(AuthForgotPasswordSent());
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(AuthError(message: e.firstError));
      } else {
        emit(const AuthError(
            message: 'Failed to send reset link. Please try again.'));
      }
    }
  }

  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authRepository.resetPassword(
        token: event.token,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      emit(AuthPasswordResetSuccess());
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(AuthError(message: e.firstError));
      } else {
        emit(const AuthError(
            message: 'Password reset failed. Please try again.'));
      }
    }
  }

  Future<void> _onAuthUserRefreshRequested(
    AuthUserRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      try {
        await authRepository.refreshUser();
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        }
      } catch (e) {
        // Keep current state if refresh fails
      }
    }
  }

  Future<void> _onAuthTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final shouldRefresh = await authRepository.shouldRefreshToken();
      if (shouldRefresh) {
        await authRepository.refreshUser();
        final user = await authRepository.getCurrentUser();
        if (user != null && state is AuthAuthenticated) {
          emit(AuthAuthenticated(user: user));
        }
      }
    } catch (e) {
      // If token refresh fails, logout user
      await authRepository.logout();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSwitchToContractorMode(
    AuthSwitchToContractorMode event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      try {
        // Try to switch to contractor role
        // The repository will handle enabling the role if needed
        final updatedUser = await authRepository.switchRole('contractor');

        emit(AuthAuthenticated(user: updatedUser));
      } catch (e) {
      
        if (e is ApiErrorModel) {
          emit(AuthError(message: e.firstError));
        } else {
          emit(const AuthError(
              message:
                  'Failed to switch to contractor mode. Please try again.'));
        }
      }
    } else {
      print('User is not authenticated');
    }
  }

  Future<void> _onAuthSwitchToClientMode(
    AuthSwitchToClientMode event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      try {
        final updatedUser = await authRepository.switchRole('client');

        emit(AuthAuthenticated(user: updatedUser));
      } catch (e) {
        if (e is ApiErrorModel) {
          emit(AuthError(message: e.firstError));
        } else {
          emit(const AuthError(
              message: 'Failed to switch to client mode. Please try again.'));
        }
      }
    } else {
      print('User is not authenticated');
    }
  }

  // Helper method to check if user is authenticated
  bool get isAuthenticated => state is AuthAuthenticated;

  // Helper method to get current user
  UserModel? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }
}
