import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_urls.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/bids/bid_model.dart';
import '../../models/pagination/pagination_model.dart';

class BidsProvider {
  final FlutterSecureStorage storage;

  BidsProvider({required this.storage});

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get contractor's own bids
  Future<PaginationModel<BidModel>> getContractorBids({
    int page = 1,
    int perPage = 10,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final uri = Uri.parse(AppUrls.contractorBids).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PaginationModel<BidModel>.fromJson(
          jsonData,
          (json) => BidModel.fromJson(json as Map<String, dynamic>),
        );
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiErrorModel(
          message: 'No internet connection',
          errors: {
            'network': ['Please check your internet connection']
          },
        );
      }
      rethrow;
    }
  }

  // Get bids for a specific project (for clients)
  Future<PaginationModel<BidModel>> getProjectBids(
    int projectId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse('${AppUrls.projectBids}$projectId/bids').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Try both possible response structures
        final bidsData = jsonData['bids'] ?? jsonData;
        return PaginationModel<BidModel>.fromJson(
          bidsData,
          (json) => BidModel.fromJson(json as Map<String, dynamic>),
        );
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiErrorModel(
          message: 'No internet connection',
          errors: {
            'network': ['Please check your internet connection']
          },
        );
      }
      rethrow;
    }
  }

  // Create a bid
  Future<BidModel> createBid(BidRequestModel bidRequest) async {
    try {
      final headers = await _getAuthHeaders();
      final url = '${AppUrls.createBid}${bidRequest.projectId}/bids';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(bidRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return BidModel.fromJson(jsonData['bid']);
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiErrorModel(
          message: 'No internet connection',
          errors: {
            'network': ['Please check your internet connection']
          },
        );
      }
      rethrow;
    }
  }

  // Update a bid
  Future<BidModel> updateBid(
    int projectId,
    int bidId,
    BidRequestModel bidRequest,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final url = '${AppUrls.updateBid}$projectId/bids/$bidId';

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(bidRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return BidModel.fromJson(jsonData['bid']);
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiErrorModel(
          message: 'No internet connection',
          errors: {
            'network': ['Please check your internet connection']
          },
        );
      }
      rethrow;
    }
  }

  // Delete/withdraw a bid
  Future<void> deleteBid(int projectId, int bidId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = '${AppUrls.deleteBid}$projectId/bids/$bidId';

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiErrorModel(
          message: 'No internet connection',
          errors: {
            'network': ['Please check your internet connection']
          },
        );
      }
      rethrow;
    }
  }

  // Get single bid details
  Future<BidModel?> getBid(int projectId, int bidId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = '${AppUrls.projectBids}$projectId/bids/$bidId';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return BidModel.fromJson(jsonData['bid']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiErrorModel(
          message: 'No internet connection',
          errors: {
            'network': ['Please check your internet connection']
          },
        );
      }
      rethrow;
    }
  }
}
