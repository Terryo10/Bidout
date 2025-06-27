// lib/constants/app_urls.dart
class AppUrls {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String storageUrl = '$baseUrl/storage';

  // Auth endpoints
  static const String register = '$baseUrl/api/register';
  static const String login = '$baseUrl/api/login';
  static const String forgotPassword = '$baseUrl/api/forgot-password';
  static const String resetPassword = '$baseUrl/api/reset-password';
  static const String logout = '$baseUrl/api/logout';
  static const String me = '$baseUrl/api/me';

  // User endpoints
  static const String userProfile = '$baseUrl/api/user/profile';
  static const String updateProfile = '$baseUrl/api/user/profile';
  static const String updateAvatar = '$baseUrl/api/user/avatar';

  // Project endpoints
  static const String projects = '$baseUrl/api/projects';

  // Contractor endpoints
  static const String contractors = '$baseUrl/api/contractors';

  // Billing endpoints
  static const String subscription = '$baseUrl/api/billing/subscription';
  static const String paymentMethods = '$baseUrl/api/billing/payment-methods';
  static const String invoices = '$baseUrl/api/billing/invoices';

  static String contractorProfile(int contractorId) =>
      '$contractors/$contractorId';
  static String contractorPortfolio(int contractorId) =>
      '$contractors/$contractorId/portfolio';
  static String contractorReviews(int contractorId) =>
      '$contractors/$contractorId/reviews';

  // Helper methods for storage URLs
  static String getStorageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$storageUrl/$path';
  }

  static String getAvatarUrl(String? path) => getStorageUrl(path);
  static String getPortfolioImageUrl(String? path) => getStorageUrl(path);
}
