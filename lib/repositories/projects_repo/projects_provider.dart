import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../constants/app_urls.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/pagination/pagination_model.dart';
import '../../models/projects/project_model.dart';
import '../../models/projects/projects_response_model.dart';
import '../../models/projects/project_request_model.dart' as request;
import '../../models/services/service_model.dart' as service;

class ProjectProvider {
  final FlutterSecureStorage storage;

  ProjectProvider({required this.storage});

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<PaginationModel<ProjectModel>> getProjects({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status;
      }
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }
      
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }

      final uri = Uri.parse(AppUrls.projects).replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final projectsResponse = ProjectsResponseModel.fromJson(data);
        return projectsResponse.projects;
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load projects.');
    }
  }

  Future<ProjectModel?> getProject(int projectId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.projects}/$projectId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProjectModel.fromJson(data['project'] ?? data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load project.');
    }
  }

  Future<ProjectModel> createProject(
      request.ProjectRequestModel request) async {
    try {
      final headers = await _getMultipartHeaders();
      final uri = Uri.parse(AppUrls.projects);
      final multipartRequest = http.MultipartRequest('POST', uri);

      // Add headers
      multipartRequest.headers.addAll(headers);

      // Add text fields
      multipartRequest.fields.addAll({
        'title': request.title,
        'description': request.description,
        'budget': request.budget.toString(),
        'frequency': request.frequency,
        'key_factor': request.keyFactor,
        'start_date': request.startDate.toIso8601String().split('T')[0],
        'end_date': request.endDate.toIso8601String().split('T')[0],
        'service_id': request.serviceId.toString(),
        'is_drafted': request.isDrafted ? '1' : '0',
      });

      // Add optional fields
      if (request.additionalRequirements != null) {
        multipartRequest.fields['additionalRequirements'] =
            request.additionalRequirements!;
      }
      if (request.street != null) {
        multipartRequest.fields['street'] = request.street!;
      }
      if (request.city != null) {
        multipartRequest.fields['city'] = request.city!;
      }
      if (request.state != null) {
        multipartRequest.fields['state'] = request.state!;
      }
      if (request.zipCode != null) {
        multipartRequest.fields['zip_code'] = request.zipCode!;
      }

      // Add image files
      for (int i = 0; i < request.images.length; i++) {
        final imagePath = request.images[i];
        final file = File(imagePath);

        if (await file.exists()) {
          final mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';
          final mimeTypeData = mimeType.split('/');

          final multipartFile = await http.MultipartFile.fromPath(
            'images[$i]',
            imagePath,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          );
          multipartRequest.files.add(multipartFile);
        }
      }

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ProjectModel.fromJson(data['project'] ?? data);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to create project.');
    }
  }

  Future<ProjectModel> updateProject(
      int projectId, request.ProjectRequestModel request) async {
    try {
      final headers = await _getMultipartHeaders();
      final uri = Uri.parse('${AppUrls.projects}/$projectId');
      final multipartRequest = http.MultipartRequest('PUT', uri);

      // Add headers
      multipartRequest.headers.addAll(headers);

      // Add text fields
      multipartRequest.fields.addAll({
        'title': request.title,
        'description': request.description,
        'budget': request.budget.toString(),
        'frequency': request.frequency,
        'key_factor': request.keyFactor,
        'start_date': request.startDate.toIso8601String().split('T')[0],
        'end_date': request.endDate.toIso8601String().split('T')[0],
        'service_id': request.serviceId.toString(),
        'is_drafted': request.isDrafted ? '1' : '0',
        '_method': 'PUT', // Laravel method spoofing
      });

      // Add optional fields
      if (request.additionalRequirements != null) {
        multipartRequest.fields['additionalRequirements'] =
            request.additionalRequirements!;
      }
      if (request.street != null) {
        multipartRequest.fields['street'] = request.street!;
      }
      if (request.city != null) {
        multipartRequest.fields['city'] = request.city!;
      }
      if (request.state != null) {
        multipartRequest.fields['state'] = request.state!;
      }
      if (request.zipCode != null) {
        multipartRequest.fields['zip_code'] = request.zipCode!;
      }

      // Add image files
      for (int i = 0; i < request.images.length; i++) {
        final imagePath = request.images[i];
        final file = File(imagePath);

        if (await file.exists()) {
          final mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';
          final mimeTypeData = mimeType.split('/');

          final multipartFile = await http.MultipartFile.fromPath(
            'images[$i]',
            imagePath,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          );
          multipartRequest.files.add(multipartFile);
        }
      }

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProjectModel.fromJson(data['project'] ?? data);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to update project.');
    }
  }

  Future<void> deleteProject(int projectId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${AppUrls.projects}/$projectId'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to delete project.');
    }
  }

  Future<List<service.ServiceModel>> getServices() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.baseUrl}/services'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> servicesJson = data['services'] ?? [];
        return servicesJson
            .map((json) => service.ServiceModel.fromJson(json))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load services.');
    }
  }
}