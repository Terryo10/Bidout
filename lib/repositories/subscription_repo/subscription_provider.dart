import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_urls.dart';
import '../../models/auth/api_error_model.dart';
import '../../models/subscription/subscription_package.dart';
import '../../models/subscription/user_subscription.dart';
import '../../models/subscription/bid_package.dart';
import '../../models/subscription/bid_purchase.dart';

class SubscriptionProvider {
  final FlutterSecureStorage storage;

  SubscriptionProvider({required this.storage});

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode >= 400) {
      if (response.body.isNotEmpty) {
        try {
          final errorData = json.decode(response.body);
          throw ApiErrorModel.fromJson(errorData);
        } catch (e) {
          throw ApiErrorModel(
            message: 'An error occurred',
            errors: {
              'general': ['Server error: ${response.statusCode}']
            },
          );
        }
      } else {
        throw ApiErrorModel(
          message: 'An error occurred',
          errors: {
            'general': ['Server error: ${response.statusCode}']
          },
        );
      }
    }
  }

  // Get subscription packages
  Future<List<SubscriptionPackage>> getSubscriptionPackages() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(AppUrls.subscriptionPackages),
        headers: headers,
      );

      _handleResponse(response);

      final data = json.decode(response.body);
      final packages = data['data'] as List? ?? [];

      return packages
          .map((package) => SubscriptionPackage.fromJson(package))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get user's active subscription
  Future<UserSubscription?> getActiveSubscription() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(AppUrls.userSubscription),
        headers: headers,
      );

      if (response.statusCode == 404) {
        return null; // No active subscription
      }

      _handleResponse(response);

      final data = json.decode(response.body);
      if (data['data'] != null) {
        return UserSubscription.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get bid packages
  Future<List<BidPackage>> getBidPackages() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(AppUrls.bidPackages),
        headers: headers,
      );

      _handleResponse(response);

      final data = json.decode(response.body);
      final packages = data['data'] as List? ?? [];

      return packages.map((package) => BidPackage.fromJson(package)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get bid purchase history
  Future<List<BidPurchase>> getBidPurchaseHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(AppUrls.bidPurchases),
        headers: headers,
      );

      _handleResponse(response);

      final data = json.decode(response.body);
      final purchases = data['data'] as List? ?? [];

      return purchases
          .map((purchase) => BidPurchase.fromJson(purchase))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get bid status
  Future<Map<String, dynamic>> getBidStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(AppUrls.bidStatus),
        headers: headers,
      );

      _handleResponse(response);

      final data = json.decode(response.body);
      return data['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  // Subscribe to package
  Future<Map<String, dynamic>> subscribeToPackage(
    int packageId, {
    String? paymentMethodId,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'package_id': packageId,
        if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      };

      final response = await http.post(
        Uri.parse(AppUrls.subscribe),
        headers: headers,
        body: json.encode(body),
      );

      _handleResponse(response);

      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  // Cancel subscription
  Future<UserSubscription> cancelSubscription(int subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(AppUrls.cancelSubscription
            .replaceAll('{id}', subscriptionId.toString())),
        headers: headers,
      );

      _handleResponse(response);

      final data = json.decode(response.body);
      return UserSubscription.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Resume subscription
  Future<UserSubscription> resumeSubscription(int subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(AppUrls.resumeSubscription
            .replaceAll('{id}', subscriptionId.toString())),
        headers: headers,
      );

      _handleResponse(response);

      final data = json.decode(response.body);
      return UserSubscription.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Update subscription
  Future<UserSubscription> updateSubscription(
    int subscriptionId,
    int newPackageId,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = {'package_id': newPackageId};

      final response = await http.put(
        Uri.parse(AppUrls.updateSubscription
            .replaceAll('{id}', subscriptionId.toString())),
        headers: headers,
        body: json.encode(body),
      );

      _handleResponse(response);

      final data = json.decode(response.body);
      return UserSubscription.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Purchase bids
  Future<Map<String, dynamic>> purchaseBids(
    int packageId, {
    String? paymentMethodId,
    String? promoCode,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'package_id': packageId,
        if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
        if (promoCode != null) 'promo_code': promoCode,
      };

      final response = await http.post(
        Uri.parse(AppUrls.buyBids),
        headers: headers,
        body: json.encode(body),
      );

      _handleResponse(response);

      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  // Confirm payment
  Future<void> confirmPayment(String paymentIntentId) async {
    try {
      final headers = await _getHeaders();
      final body = {'payment_intent_id': paymentIntentId};

      final response = await http.post(
        Uri.parse(AppUrls.confirmPayment),
        headers: headers,
        body: json.encode(body),
      );

      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
