import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/subscription/subscription_package.dart';
import '../../models/subscription/user_subscription.dart';
import '../../models/subscription/bid_package.dart';
import '../../models/subscription/bid_purchase.dart';
import 'subscription_provider.dart';

class SubscriptionRepository {
  final FlutterSecureStorage storage;
  final SubscriptionProvider subscriptionProvider;

  SubscriptionRepository({
    required this.storage,
    required this.subscriptionProvider,
  });

  // Get subscription packages
  Future<List<SubscriptionPackage>> getSubscriptionPackages() async {
    try {
      return await subscriptionProvider.getSubscriptionPackages();
    } catch (e) {
      rethrow;
    }
  }

  // Get user's active subscription
  Future<UserSubscription?> getActiveSubscription() async {
    try {
      return await subscriptionProvider.getActiveSubscription();
    } catch (e) {
      rethrow;
    }
  }

  // Get bid packages
  Future<List<BidPackage>> getBidPackages() async {
    try {
      return await subscriptionProvider.getBidPackages();
    } catch (e) {
      rethrow;
    }
  }

  // Get bid purchase history
  Future<List<BidPurchase>> getBidPurchaseHistory() async {
    try {
      return await subscriptionProvider.getBidPurchaseHistory();
    } catch (e) {
      rethrow;
    }
  }

  // Get bid status
  Future<Map<String, dynamic>> getBidStatus() async {
    try {
      return await subscriptionProvider.getBidStatus();
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
      return await subscriptionProvider.subscribeToPackage(
        packageId,
        paymentMethodId: paymentMethodId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Cancel subscription
  Future<UserSubscription> cancelSubscription(int subscriptionId) async {
    try {
      return await subscriptionProvider.cancelSubscription(subscriptionId);
    } catch (e) {
      rethrow;
    }
  }

  // Resume subscription
  Future<UserSubscription> resumeSubscription(int subscriptionId) async {
    try {
      return await subscriptionProvider.resumeSubscription(subscriptionId);
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
      return await subscriptionProvider.updateSubscription(
        subscriptionId,
        newPackageId,
      );
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
      return await subscriptionProvider.purchaseBids(
        packageId,
        paymentMethodId: paymentMethodId,
        promoCode: promoCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Confirm payment
  Future<void> confirmPayment(String paymentIntentId) async {
    try {
      await subscriptionProvider.confirmPayment(paymentIntentId);
    } catch (e) {
      rethrow;
    }
  }
}
