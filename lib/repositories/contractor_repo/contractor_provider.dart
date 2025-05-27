// lib/repositories/contractors_repo/contractors_provider.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_urls.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/contractors/contractor_model.dart';

class ContractorsProvider {
  final FlutterSecureStorage storage;

  ContractorsProvider({required this.storage});

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

  Future<List<ContractorModel>> getContractors({
    String? search,
    String? service,
    double? minRating,
    String? sortBy,
    String? sortOrder,
    bool? featured,
    String? location,
    bool? availableForHire,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (service != null && service.isNotEmpty) {
        queryParams['service'] = service;
      }
      
      if (minRating != null) {
        queryParams['min_rating'] = minRating.toString();
      }
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
        queryParams['sort_order'] = sortOrder ?? 'desc';
      }
      
      if (featured != null && featured) {
        queryParams['featured'] = 'true';
      }
      
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      
      if (availableForHire != null && availableForHire) {
        queryParams['available'] = 'true';
      }

      final uri = Uri.parse(AppUrls.contractors).replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> contractorsJson = data['contractors'] ?? data['data'] ?? [];
        
        return contractorsJson
            .map((json) => ContractorModel.fromJson(json))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
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

  Future<List<PortfolioItemModel>> getContractorPortfolio(int contractorId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.contractors}/$contractorId/portfolio'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> portfolioJson = data['portfolio'] ?? data['data'] ?? [];
        
        return portfolioJson
            .map((json) => PortfolioItemModel.fromJson(json))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw ApiErrorModel.fromJson(error);
      }
    } catch (e) {
      if (e is ApiErrorModel) rethrow;
      throw ApiErrorModel(message: 'Failed to load contractor portfolio: $e');
    }
  }

  Future<List<ContractorReviewModel>> getContractorReviews(int contractorId) async {
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

  Future<List<ContractorModel>> getFeaturedContractors() async {
    return getContractors(featured: true, sortBy: 'rating', sortOrder: 'desc');
  }

  Future<List<ContractorModel>> searchContractors(String query) async {
    return getContractors(search: query);
  }
}

// lib/repositories/contractors_repo/contractors_repository.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/contractors/contractor_model.dart';
import 'contractors_provider.dart';

class ContractorRepository {
  final FlutterSecureStorage storage;
  final ContractorsProvider contractorsProvider;

  ContractorRepository({
    required this.storage,
    required this.contractorsProvider,
  });

  Future<List<ContractorModel>> getContractors({
    String? search,
    String? service,
    double? minRating,
    String? sortBy,
    String? sortOrder,
    bool? featured,
    String? location,
    bool? availableForHire,
  }) async {
    return await contractorsProvider.getContractors(
      search: search,
      service: service,
      minRating: minRating,
      sortBy: sortBy,
      sortOrder: sortOrder,
      featured: featured,
      location: location,
      availableForHire: availableForHire,
    );
  }

  Future<ContractorModel?> getContractor(int contractorId) async {
    return await contractorsProvider.getContractor(contractorId);
  }

  Future<List<PortfolioItemModel>> getContractorPortfolio(int contractorId) async {
    return await contractorsProvider.getContractorPortfolio(contractorId);
  }

  Future<List<ContractorReviewModel>> getContractorReviews(int contractorId) async {
    return await contractorsProvider.getContractorReviews(contractorId);
  }

  Future<List<ContractorModel>> getFeaturedContractors() async {
    return await contractorsProvider.getFeaturedContractors();
  }

  Future<List<ContractorModel>> searchContractors(String query) async {
    return await contractorsProvider.searchContractors(query);
  }
}