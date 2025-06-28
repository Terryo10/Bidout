class StripeConfig {
  // Test keys - Replace with your actual Stripe keys
  static const String publishableKey =
      'pk_test_51HDZszIkDRRtoJvtfBcQdRvmwWqN0uGqpPheS3abi2lK5IoSxZCs7vyDbmaun2PWh2H9ttCmdSikGSGUgZO8qMM900A74yF8O7'; // Your Stripe publishable key

  // Production keys (use environment variables in production)
  // static const String publishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static bool get isTestMode => publishableKey.startsWith('pk_test_');
}
