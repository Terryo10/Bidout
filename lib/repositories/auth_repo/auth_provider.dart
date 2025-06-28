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

  Map<String, String> _getHeaders() {
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

  Future<Map<String, dynamic>> getRoleInfo() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(AppUrls.getRoleInfo),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to get role info.');
    }
  }

  Future<UserModel> switchRole(String role) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(AppUrls.switchRole),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'role': role}),
      );

      print('Switch role response: ${response.body}');
      final data = jsonDecode(response.body);
      print('Decoded response data: $data');

      if (response.statusCode == 200) {
        if (data['user'] != null) {
          // Extract user data from nested response
          final Map<String, dynamic> userData =
              Map<String, dynamic>.from(data['user']);
          print('User data before parsing: $userData');

          // Add any missing fields from the root level
          userData['active_role'] =
              userData['active_role'] ?? userData['user_type'];
          userData['available_roles'] = userData['available_roles'] ?? [];
          userData['is_dual_role'] = userData['is_dual_role'] ?? false;
          userData['contractor_status'] = userData['contractor_status'];
          userData['formatted_roles'] = userData['formatted_roles'];

          // Add default values for potentially null fields
          userData['free_bids_remaining'] =
              userData['free_bids_remaining'] ?? 0;
          userData['total_free_bids_granted'] =
              userData['total_free_bids_granted'] ?? 0;
          userData['purchased_bids_remaining'] =
              userData['purchased_bids_remaining'] ?? 0;
          userData['total_bids_purchased'] =
              userData['total_bids_purchased'] ?? 0;
          userData['total_reviews'] = userData['total_reviews'] ?? 0;
          userData['rating'] = userData['rating']?.toString() ?? '0.0';
          userData['is_featured'] = userData['is_featured'] ?? false;
          userData['available_for_hire'] =
              userData['available_for_hire'] ?? true;

          print('User data after defaults: $userData');
          return UserModel.fromJson(userData);
        } else {
          throw ApiErrorModel(message: 'Invalid response format from server');
        }
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      print('Error in switchRole: $e');
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to switch role: ${e.toString()}');
    }
  }

  Future<UserModel> enableRole(String role) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(AppUrls.enableRole),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'role': role}),
      );


      final data = jsonDecode(response.body);


      if (response.statusCode == 200) {
        if (data['user'] != null) {
          // Extract user data from nested response
          final Map<String, dynamic> userData =
              Map<String, dynamic>.from(data['user']);
    

          // Add any missing fields from the root level
          userData['active_role'] =
              userData['active_role'] ?? userData['user_type'];
          userData['available_roles'] = userData['available_roles'] ?? [];
          userData['is_dual_role'] = userData['is_dual_role'] ?? false;
          userData['contractor_status'] = userData['contractor_status'];
          userData['formatted_roles'] = userData['formatted_roles'];

          // Add default values for potentially null fields
          userData['free_bids_remaining'] =
              userData['free_bids_remaining'] ?? 0;
          userData['total_free_bids_granted'] =
              userData['total_free_bids_granted'] ?? 0;
          userData['purchased_bids_remaining'] =
              userData['purchased_bids_remaining'] ?? 0;
          userData['total_bids_purchased'] =
              userData['total_bids_purchased'] ?? 0;
          userData['total_reviews'] = userData['total_reviews'] ?? 0;
          userData['rating'] = userData['rating']?.toString() ?? '0.0';
          userData['is_featured'] = userData['is_featured'] ?? false;
          userData['available_for_hire'] =
              userData['available_for_hire'] ?? true;


          return UserModel.fromJson(userData);
        } else {
          throw ApiErrorModel(message: 'Invalid response format from server');
        }
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {

      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to enable role: ${e.toString()}');
    }
  }
}
