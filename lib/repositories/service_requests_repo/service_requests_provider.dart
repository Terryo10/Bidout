import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/app_urls.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/service_request_model.dart';

class ServiceRequestsProvider {
  final FlutterSecureStorage storage;

  ServiceRequestsProvider({required this.storage});

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<ServiceRequestsResponse> getServiceRequests({
    int page = 1,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(AppUrls.serviceRequests).replace(
        queryParameters: {
          'page': page.toString(),
          if (status != null) 'status': status,
        },
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceRequestsResponse.fromJson(data['service_requests']);
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        rethrow;
      }
      throw ApiErrorModel(message: 'Failed to load service requests: $e');
    }
  }

  Future<ServiceRequestModel> createServiceRequest(
      CreateServiceRequestModel request) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(AppUrls.serviceRequests),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ServiceRequestModel.fromJson(data['service_request']);
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        rethrow;
      }
      throw ApiErrorModel(message: 'Failed to send service request: $e');
    }
  }

  Future<ServiceRequestModel> getServiceRequest(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppUrls.serviceRequestDetails}$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceRequestModel.fromJson(data['service_request']);
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        rethrow;
      }
      throw ApiErrorModel(message: 'Failed to load service request: $e');
    }
  }

  Future<ServiceRequestModel> updateServiceRequestStatus(
      int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('${AppUrls.updateServiceRequestStatus}$id/status'),
        headers: headers,
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceRequestModel.fromJson(data['service_request']);
      } else {
        final errorData = json.decode(response.body);
        throw ApiErrorModel.fromJson(errorData);
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        rethrow;
      }
      throw ApiErrorModel(message: 'Failed to update service request: $e');
    }
  }
}
