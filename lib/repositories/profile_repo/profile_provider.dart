// lib/repositories/profile_repo/profile_provider.dart
import 'dart:convert';

import 'package:bidout/constants/app_urls.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../models/user_model.dart';

class ProfileProvider {
  final FlutterSecureStorage storage;
  final String baseUrl = AppUrls.apiUrl;

  ProfileProvider({required this.storage});

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Get multipart headers for file uploads
  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data['user'] ?? data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  // Update general profile (unified endpoint for all profile updates)
  Future<UserModel?> updateProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data['user'] ?? data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        throw Exception(
            'Validation failed: ${data['message'] ?? 'Invalid data'}');
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  // Update avatar
  Future<UserModel?> updateAvatar({
    required String imagePath,
  }) async {
    try {
      final headers = await _getMultipartHeaders();

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/avatar'),
      );

      // Add headers
      request.headers.addAll(headers);

      // Add file
      final mimeType = lookupMimeType(imagePath);
      final file = await http.MultipartFile.fromPath(
        'avatar',
        imagePath,
        contentType: mimeType != null
            ? MediaType.parse(mimeType)
            : MediaType('application', 'octet-stream'),
      );
      request.files.add(file);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // For avatar update, we need to get the updated user profile
        return await getCurrentUserProfile();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to update avatar: ${response.body}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  // Update contractor-specific profile (uses unified endpoint)
  Future<UserModel?> updateContractorProfile({
    required Map<String, dynamic> contractorData,
  }) async {
    return updateProfile(profileData: contractorData);
  }

  // Update client-specific profile (uses unified endpoint)
  Future<UserModel?> updateClientProfile({
    required Map<String, dynamic> clientData,
  }) async {
    return updateProfile(profileData: clientData);
  }

  // Update contractor services (uses unified endpoint)
  Future<UserModel?> updateContractorServices({
    required List<Map<String, dynamic>> services,
  }) async {
    return updateProfile(profileData: {'services': services});
  }

  // Update contractor skills (uses unified endpoint)
  Future<UserModel?> updateContractorSkills({
    required List<String> skills,
  }) async {
    return updateProfile(profileData: {'skills': skills});
  }

  // Update contractor certifications (uses unified endpoint)
  Future<UserModel?> updateContractorCertifications({
    required List<String> certifications,
  }) async {
    return updateProfile(profileData: {'certifications': certifications});
  }
}
