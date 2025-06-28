import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/stripe_config.dart';

class StripeService {
  static const String publishableKey =
      'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY'; // Replace with your actual key

  static Future<void> init() async {
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Show payment sheet for subscription
  static Future<bool> showSubscriptionPaymentSheet({
    required String clientSecret,
    required String packageName,
    required double amount,
  }) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Bidout',
          customFlow: false,
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF1976D2),
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      print('Stripe error: ${e.error.localizedMessage}');
      // Return false for user-cancelled payments, but don't throw
      if (e.error.code == FailureCode.Canceled) {
        print('Payment was cancelled by user');
        return false;
      }
      throw Exception('Payment failed: ${e.error.localizedMessage}');
    } catch (e) {
      print('Error showing payment sheet: $e');
      throw Exception('Payment initialization failed: $e');
    }
  }

  /// Show payment sheet for bid purchase
  static Future<bool> showBidPurchasePaymentSheet({
    required String clientSecret,
    required String packageName,
    required double amount,
    required int bidCount,
  }) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Bidout',
          customFlow: false,
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF1976D2),
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      print('Stripe error: ${e.error.localizedMessage}');
      // Return false for user-cancelled payments, but don't throw
      if (e.error.code == FailureCode.Canceled) {
        print('Payment was cancelled by user');
        return false;
      }
      throw Exception('Payment failed: ${e.error.localizedMessage}');
    } catch (e) {
      print('Error showing payment sheet: $e');
      throw Exception('Payment initialization failed: $e');
    }
  }

  /// Extract payment intent ID from client secret
  static String getPaymentIntentFromClientSecret(String clientSecret) {
    return clientSecret.split('_secret_')[0];
  }
}
