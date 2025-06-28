import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/service_request_model.dart';
import '../../models/auth/api_error_model.dart';
import 'service_requests_provider.dart';

class ServiceRequestsRepository {
  final FlutterSecureStorage storage;
  final ServiceRequestsProvider serviceRequestsProvider;

  ServiceRequestsRepository({
    required this.storage,
    required this.serviceRequestsProvider,
  });

  Future<ServiceRequestsResponse> getServiceRequests({
    int page = 1,
    String? status,
  }) async {
    try {
      return await serviceRequestsProvider.getServiceRequests(
        page: page,
        status: status,
      );
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
      return await serviceRequestsProvider.createServiceRequest(request);
    } catch (e) {
      if (e is ApiErrorModel) {
        rethrow;
      }
      throw ApiErrorModel(message: 'Failed to send service request: $e');
    }
  }

  Future<ServiceRequestModel> getServiceRequest(int id) async {
    try {
      return await serviceRequestsProvider.getServiceRequest(id);
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
      return await serviceRequestsProvider.updateServiceRequestStatus(
          id, status);
    } catch (e) {
      if (e is ApiErrorModel) {
        rethrow;
      }
      throw ApiErrorModel(message: 'Failed to update service request: $e');
    }
  }

  Future<ServiceRequestsResponse> getClientServiceRequests({
    int page = 1,
    String? status,
  }) async {
    return getServiceRequests(page: page, status: status);
  }

  Future<ServiceRequestsResponse> getContractorServiceRequests({
    int page = 1,
    String? status,
  }) async {
    return getServiceRequests(page: page, status: status);
  }
}
