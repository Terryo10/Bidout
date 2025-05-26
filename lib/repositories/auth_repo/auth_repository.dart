import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/auth/auth_response_model.dart';
import '../../models/auth/register_request_model.dart';
import '../../models/auth/login_request_model.dart';
import '../../models/user_model.dart';
import 'auth_provider.dart';

class AuthRepository {
  final FlutterSecureStorage storage;
  final AuthProvider authProvider;

  AuthRepository({required this.storage, required this.authProvider});

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

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
    await authProvider.logout();
    await _clearAuthData();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // First try to get from storage
      final userJson = await storage.read(key: userKey);
      if (userJson != null) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(
              // You'll need to decode this properly based on how it's stored
              {}),
        );
      }

      // If not in storage, fetch from API
      final user = await authProvider.getCurrentUser();
      await _saveUserData(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: tokenKey);
    final isLoggedIn = await storage.read(key: isLoggedInKey);
    return token != null && isLoggedIn == 'true';
  }

  Future<String?> getAuthToken() async {
    return await storage.read(key: tokenKey);
  }

  Future<void> _saveAuthData(AuthResponseModel response) async {
    await storage.write(key: tokenKey, value: response.token);
    await storage.write(key: isLoggedInKey, value: 'true');
    await _saveUserData(response.user);
  }

  Future<void> _saveUserData(UserModel user) async {
    await storage.write(key: userKey, value: user.toJson().toString());
  }

  Future<void> _clearAuthData() async {
    await storage.delete(key: tokenKey);
    await storage.delete(key: userKey);
    await storage.delete(key: isLoggedInKey);
  }

  Future<void> refreshUser() async {
    try {
      final user = await authProvider.getCurrentUser();
      await _saveUserData(user);
    } catch (e) {
      // Handle error if needed
    }
  }
}
