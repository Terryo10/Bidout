import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_urls.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/pagination/pagination_model.dart';
import '../../models/projects/project_model.dart';
import '../../models/projects/project_detail_response_model.dart';
import '../../models/projects/projects_response_model.dart';

class ContractorProjectsProvider {
  final FlutterSecureStorage storage;

  ContractorProjectsProvider({required this.storage});

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

  Future<PaginationModel<ProjectModel>> getAvailableProjects({
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
        'contractor_view': 'true', // Flag to indicate contractor view
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

      final uri =
          Uri.parse(AppUrls.projects).replace(queryParameters: queryParams);

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
      throw ApiErrorModel(message: 'Failed to load available projects.');
    }
  }

  Future<ProjectDetailResponseModel?> getProject(int projectId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.projects}/$projectId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProjectDetailResponseModel.fromJson(data);
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
}
