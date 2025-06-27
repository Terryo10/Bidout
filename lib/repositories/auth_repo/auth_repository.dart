import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/auth/auth_response_model.dart';
import '../../models/auth/register_request_model.dart';
import '../../models/auth/login_request_model.dart';
import '../../models/user_model.dart';
import '../../models/auth/api_error_model.dart';
import 'auth_provider.dart';

class AuthRepository {
  final FlutterSecureStorage storage;
  final AuthProvider authProvider;

  AuthRepository({required this.storage, required this.authProvider});

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String tokenExpiryKey = 'token_expiry';

  Future<UserModel> register(RegisterRequestModel request) async {
    final response = await authProvider.register(request);
    await _saveAuthData(response);
    return response.user;
  }

  Future<UserModel> login(LoginRequestModel request) async {
    final response = await authProvider.login(request);
    await _saveAuthData(response);
    return response.user;
  }

  Future<void> forgotPassword(String email) async {
    await authProvider.forgotPassword(email);
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await authProvider.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  Future<void> logout() async {
    try {
      await authProvider.logout();
    } catch (e) {
      // Continue with local logout even if server logout fails
    } finally {
      await _clearAuthData();
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // First try to get from storage
      final userJson = await storage.read(key: userKey);
      if (userJson != null && userJson.isNotEmpty) {
        try {
          final userData = json.decode(userJson);
          final user = UserModel.fromJson(userData);

          // Check if we should refresh user data (optional: refresh every 24 hours)
          final lastRefresh = await storage.read(key: 'last_user_refresh');
          final now = DateTime.now().millisecondsSinceEpoch;

          if (lastRefresh == null ||
              (now - int.parse(lastRefresh)) > (24 * 60 * 60 * 1000)) {
            // Try to refresh user data, but don't fail if it doesn't work
            try {
              await refreshUser();
              final refreshedUserJson = await storage.read(key: userKey);
              if (refreshedUserJson != null) {
                final refreshedUserData = json.decode(refreshedUserJson);
                return UserModel.fromJson(refreshedUserData);
              }
            } catch (e) {
              // If refresh fails, return cached user
            }
          }

          return user;
        } catch (e) {
          // If parsing fails, clear corrupted data and fetch fresh
          await _clearUserData();
        }
      }

      // If not in storage or corrupted, fetch from API
      final user = await authProvider.getCurrentUser();
      await _saveUserData(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await storage.read(key: tokenKey);
      final isLoggedIn = await storage.read(key: isLoggedInKey);

      if (token == null || isLoggedIn != 'true') {
        return false;
      }

      // Check token expiry if we have it stored
      final expiryString = await storage.read(key: tokenExpiryKey);
      if (expiryString != null) {
        final expiry =
            DateTime.fromMillisecondsSinceEpoch(int.parse(expiryString));
        if (DateTime.now().isAfter(expiry)) {
          await _clearAuthData();
          return false;
        }
      }

      // Verify token is still valid by trying to get current user
      try {
        final user = await getCurrentUser();
        return user != null;
      } catch (e) {
        // If token is invalid, clear auth data
        await _clearAuthData();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAuthToken() async {
    return await storage.read(key: tokenKey);
  }

  Future<void> _saveAuthData(AuthResponseModel response) async {
    await storage.write(key: tokenKey, value: response.token);
    await storage.write(key: isLoggedInKey, value: 'true');

    // Set token expiry (assume 24 hours if not provided)
    final expiry = DateTime.now().add(const Duration(hours: 24));
    await storage.write(
        key: tokenExpiryKey, value: expiry.millisecondsSinceEpoch.toString());

    await _saveUserData(response.user);
  }

  Future<void> _saveUserData(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await storage.write(key: userKey, value: userJson);
      await storage.write(
          key: 'last_user_refresh',
          value: DateTime.now().millisecondsSinceEpoch.toString());
    } catch (e) {
      // Handle encoding errors gracefully
    }
  }

  Future<void> _clearUserData() async {
    await storage.delete(key: userKey);
    await storage.delete(key: 'last_user_refresh');
  }

  Future<void> _clearAuthData() async {
    await storage.delete(key: tokenKey);
    await storage.delete(key: userKey);
    await storage.delete(key: isLoggedInKey);
    await storage.delete(key: tokenExpiryKey);
    await storage.delete(key: 'last_user_refresh');
  }

  Future<void> refreshUser() async {
    try {
      final user = await authProvider.getCurrentUser();
      await _saveUserData(user);
    } catch (e) {
      // Handle error if needed, but don't throw
    }
  }

  // Method to check if token needs refresh (optional enhancement)
  Future<bool> shouldRefreshToken() async {
    final expiryString = await storage.read(key: tokenExpiryKey);
    if (expiryString == null) return false;

    final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryString));
    final now = DateTime.now();

    // Refresh if token expires in less than 1 hour
    return expiry.difference(now).inHours < 1;
  }

  Future<Map<String, dynamic>> getRoleInfo() async {
    return await authProvider.getRoleInfo();
  }

  Future<UserModel> switchRole(String role) async {
    try {
      // Get role info first to check if we need to enable the role
      final roleInfo = await getRoleInfo();
      final availableRoles =
          List<String>.from(roleInfo['user']['available_roles'] ?? []);

      // If user doesn't have the role, enable it first
      if (!availableRoles.contains(role)) {
        try {
          await enableRole(role);
        } catch (e) {
          // If the error is "already has role", we can proceed
          // Otherwise, rethrow the error
          if (e is ApiErrorModel &&
              e.message != 'You already have access to this role') {
            rethrow;
          }
          // If they already have the role, we can proceed to switching
          print('User already has $role role, proceeding with switch');
        }
      }

      // Now switch to the role
      final user = await authProvider.switchRole(role);
      await _saveUserData(user);
      return user;
    } catch (e) {
      print('Error in switchRole: $e');
      rethrow;
    }
  }

  Future<UserModel> enableRole(String role) async {
    try {
      final user = await authProvider.enableRole(role);
      await _saveUserData(user);
      return user;
    } catch (e) {
      print('Error in enableRole: $e');
      rethrow;
    }
  }
}
