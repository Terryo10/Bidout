// lib/repositories/contractor_repo/contractor_provider.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_urls.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/contractor/contractor_model.dart';
import '../../models/contractor/portfolio_model.dart';
import '../../models/contractor/contractor_review_model.dart';
import '../../models/pagination/pagination_model.dart';

class ContractorProvider {
  final FlutterSecureStorage storage;

  ContractorProvider({required this.storage});

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

  Future<PaginationModel<ContractorModel>> getContractors({
    int page = 1,
    int perPage = 10,
    String? search,
    List<String>? services,
    double? minRating,
    String? location,
    bool? isFeatured,
    bool? hasSubscription,
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

      if (services != null && services.isNotEmpty) {
        queryParams['services'] = services.join(',');
      }

      if (minRating != null) {
        queryParams['min_rating'] = minRating.toString();
      }

      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      if (isFeatured != null) {
        queryParams['is_featured'] = isFeatured.toString();
      }

      if (hasSubscription != null) {
        queryParams['has_subscription'] = hasSubscription.toString();
      }

      final uri =
          Uri.parse(AppUrls.contractors).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          // Check if the response has the expected structure
          if (data is! Map<String, dynamic>) {
            throw ApiErrorModel(
                message: 'Invalid response format: expected a JSON object');
          }

          if (!data.containsKey('contractors')) {
            throw ApiErrorModel(
                message: 'Invalid response format: missing contractors key');
          }

          final contractorsData = data['contractors'];
          if (contractorsData is! Map<String, dynamic>) {
            throw ApiErrorModel(
                message:
                    'Invalid response format: contractors is not a JSON object');
          }

          return PaginationModel<ContractorModel>.fromJson(
            contractorsData,
            (json) {
              if (json is! Map<String, dynamic>) {
                throw ApiErrorModel(message: 'Invalid contractor data format');
              }
              return ContractorModel.fromJson(json);
            },
          );
        } catch (e) {
          print('Error parsing response: ${response.body}');
          if (e is ApiErrorModel) rethrow;
          throw ApiErrorModel(message: 'Failed to parse response: $e');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          throw ApiErrorModel.fromJson(error);
        } catch (e) {
          throw ApiErrorModel(message: 'Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load contractors: $e');
    }
  }

  Future<ContractorModel?> getContractor(int contractorId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.contractors}/$contractorId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ContractorModel.fromJson(data['contractor'] ?? data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load contractor details: $e');
    }
  }

  Future<PaginationModel<PortfolioModel>> getContractorPortfolio(
    int contractorId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.contractors}/$contractorId/portfolio')
            .replace(queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        }),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaginationModel<PortfolioModel>.fromJson(
          data,
          (json) => PortfolioModel.fromJson(json),
        );
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load contractor portfolio: $e');
    }
  }

  Future<PaginationModel<PortfolioModel>> getMyPortfolio({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.contractors}/me/portfolio')
            .replace(queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        }),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaginationModel<PortfolioModel>.fromJson(
          data,
          (json) => PortfolioModel.fromJson(json),
        );
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load your portfolio: $e');
    }
  }

  Future<PortfolioModel> createPortfolio({
    required String title,
    required String description,
    String? projectType,
    DateTime? completionDate,
    double? projectValue,
    String? clientName,
    String? clientTestimonial,
    List<String>? tags,
    bool isFeatured = false,
    List<String> imagePaths = const [],
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${AppUrls.contractors}/me/portfolio'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'project_type': projectType,
          'completion_date': completionDate?.toIso8601String(),
          'project_value': projectValue,
          'client_name': clientName,
          'client_testimonial': clientTestimonial,
          'tags': tags,
          'is_featured': isFeatured,
          'image_paths': imagePaths,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PortfolioModel.fromJson(data['portfolio'] ?? data);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to create portfolio item: $e');
    }
  }

  Future<PortfolioModel> updatePortfolio(
    int portfolioId, {
    required String title,
    required String description,
    String? projectType,
    DateTime? completionDate,
    double? projectValue,
    String? clientName,
    String? clientTestimonial,
    List<String>? tags,
    bool isFeatured = false,
    List<String> imagePaths = const [],
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('${AppUrls.contractors}/me/portfolio/$portfolioId'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'project_type': projectType,
          'completion_date': completionDate?.toIso8601String(),
          'project_value': projectValue,
          'client_name': clientName,
          'client_testimonial': clientTestimonial,
          'tags': tags,
          'is_featured': isFeatured,
          'image_paths': imagePaths,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PortfolioModel.fromJson(data['portfolio'] ?? data);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to update portfolio item: $e');
    }
  }

  Future<void> deletePortfolio(int portfolioId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${AppUrls.contractors}/me/portfolio/$portfolioId'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to delete portfolio item: $e');
    }
  }

  Future<List<ContractorReviewModel>> getContractorReviews(
      int contractorId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.contractors}/$contractorId/reviews'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> reviewsJson = data['reviews'] ?? data['data'] ?? [];

        return reviewsJson
            .map((json) => ContractorReviewModel.fromJson(json))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load contractor reviews: $e');
    }
  }
}
