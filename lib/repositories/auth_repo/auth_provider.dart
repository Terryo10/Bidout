// lib/repositories/auth_repo/auth_provider.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_urls.dart';
import '../../models/auth/auth_response_model.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/auth/register_request_model.dart';
import '../../models/auth/login_request_model.dart';
import '../../models/user_model.dart';

class AuthProvider {
  final FlutterSecureStorage storage;

  AuthProvider({required this.storage});

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return headers;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.register),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AuthResponseModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Registration failed. Please try again.');
    }
  }

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.login),
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponseModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Login failed. Please try again.');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.forgotPassword),
        headers: _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(
          message: 'Failed to send reset link. Please try again.');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.resetPassword),
        headers: _getHeaders(),
        body: jsonEncode({
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Password reset failed. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      final headers = await _getAuthHeaders();
      await http.post(
        Uri.parse(AppUrls.logout),
        headers: headers,
      );
    } catch (e) {
      // Even if logout fails on server, we'll clear local storage
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(AppUrls.me),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to get user info.');
    }
  }
}
