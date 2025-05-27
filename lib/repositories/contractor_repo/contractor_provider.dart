// lib/repositories/contractor_repo/contractor_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../constants/app_urls.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/contractor/contractor_model.dart';
import '../../models/contractor/portfolio_model.dart';
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

  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get contractors with filters
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
        queryParams['is_featured'] = isFeatured ? '1' : '0';
      }

      if (hasSubscription != null) {
        queryParams['has_subscription'] = hasSubscription ? '1' : '0';
      }

      final uri = Uri.parse('${AppUrls.baseUrl}/api/contractors')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaginationModel<ContractorModel>.fromJson(
          data['contractors'],
          (contractorJson) => ContractorModel.fromJson(contractorJson),
        );
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load contractors.');
    }
  }

  // Get single contractor
  Future<ContractorModel?> getContractor(int contractorId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.baseUrl}/api/contractors/$contractorId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ContractorModel.fromJson(data['contractor']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load contractor.');
    }
  }

  // Get contractor portfolio
  Future<PaginationModel<PortfolioModel>> getContractorPortfolio(
    int contractorId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse(
              '${AppUrls.baseUrl}/api/contractors/$contractorId/portfolio')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaginationModel<PortfolioModel>.fromJson(
          data['portfolio'],
          (portfolioJson) => PortfolioModel.fromJson(portfolioJson),
        );
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load contractor portfolio.');
    }
  }

  // Get my portfolio (for contractors)
  Future<PaginationModel<PortfolioModel>> getMyPortfolio({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse('${AppUrls.baseUrl}/api/my-portfolio')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaginationModel<PortfolioModel>.fromJson(
          data['portfolio'],
          (portfolioJson) => PortfolioModel.fromJson(portfolioJson),
        );
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load portfolio.');
    }
  }

  // Create portfolio item
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
      final headers = await _getMultipartHeaders();
      final uri = Uri.parse('${AppUrls.baseUrl}/api/portfolio');
      final multipartRequest = http.MultipartRequest('POST', uri);

      multipartRequest.headers.addAll(headers);

      multipartRequest.fields.addAll({
        'title': title,
        'description': description,
        'is_featured': isFeatured ? '1' : '0',
      });

      if (projectType != null) {
        multipartRequest.fields['project_type'] = projectType;
      }

      if (completionDate != null) {
        multipartRequest.fields['completion_date'] =
            completionDate.toIso8601String().split('T')[0];
      }

      if (projectValue != null) {
        multipartRequest.fields['project_value'] = projectValue.toString();
      }

      if (clientName != null) {
        multipartRequest.fields['client_name'] = clientName;
      }

      if (clientTestimonial != null) {
        multipartRequest.fields['client_testimonial'] = clientTestimonial;
      }

      if (tags != null) {
        multipartRequest.fields['tags'] = jsonEncode(tags);
      }

      // Add image files
      for (int i = 0; i < imagePaths.length; i++) {
        final imagePath = imagePaths[i];
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
        return PortfolioModel.fromJson(data['portfolio']);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to create portfolio item.');
    }
  }

  // Update portfolio item
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
      final headers = await _getMultipartHeaders();
      final uri = Uri.parse('${AppUrls.baseUrl}/api/portfolio/$portfolioId');
      final multipartRequest = http.MultipartRequest('PUT', uri);

      multipartRequest.headers.addAll(headers);

      multipartRequest.fields.addAll({
        'title': title,
        'description': description,
        'is_featured': isFeatured ? '1' : '0',
        '_method': 'PUT', // Laravel method spoofing
      });

      if (projectType != null) {
        multipartRequest.fields['project_type'] = projectType;
      }

      if (completionDate != null) {
        multipartRequest.fields['completion_date'] =
            completionDate.toIso8601String().split('T')[0];
      }

      if (projectValue != null) {
        multipartRequest.fields['project_value'] = projectValue.toString();
      }

      if (clientName != null) {
        multipartRequest.fields['client_name'] = clientName;
      }

      if (clientTestimonial != null) {
        multipartRequest.fields['client_testimonial'] = clientTestimonial;
      }

      if (tags != null) {
        multipartRequest.fields['tags'] = jsonEncode(tags);
      }

      // Add new image files
      for (int i = 0; i < imagePaths.length; i++) {
        final imagePath = imagePaths[i];
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
        return PortfolioModel.fromJson(data['portfolio']);
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to update portfolio item.');
    }
  }

  // Delete portfolio item
  Future<void> deletePortfolio(int portfolioId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${AppUrls.baseUrl}/api/portfolio/$portfolioId'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to delete portfolio item.');
    }
  }
}
