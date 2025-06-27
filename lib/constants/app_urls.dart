// lib/constants/app_urls.dart
class AppUrls {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String apiUrl = '$baseUrl/api';

  // Auth endpoints
  static const String login = '$apiUrl/auth/login';
  static const String register = '$apiUrl/auth/register';
  static const String forgotPassword = '$apiUrl/auth/forgot-password';
  static const String resetPassword = '$apiUrl/auth/reset-password';
  static const String verifyEmail = '$apiUrl/auth/verify-email';
  static const String resendVerification = '$apiUrl/auth/resend-verification';
  static const String logout = '$apiUrl/auth/logout';
  static const String me = '$apiUrl/auth/me';

  // User endpoints
  static const String profile = '$apiUrl/user/profile';
  static const String updateProfile = '$apiUrl/user/profile';
  static const String updateAvatar = '$apiUrl/user/avatar';
  static const String changePassword = '$apiUrl/user/password';
  static const String switchRole = '$apiUrl/user/switch-role';
  static const String enableRole = '$apiUrl/user/enable-role';

  // Project endpoints
  static const String projects = '$apiUrl/projects';
  static const String projectDetails = '$apiUrl/projects/';
  static const String createProject = '$apiUrl/projects';
  static const String updateProject = '$apiUrl/projects/';
  static const String deleteProject = '$apiUrl/projects/';

  // Contractor endpoints
  static const String contractors = '$apiUrl/contractors';
  static const String contractorDetails = '$apiUrl/contractors/';
  static const String contractorPortfolio = '$apiUrl/contractors/portfolio';
  static const String contractorReviews = '$apiUrl/contractors/reviews';
  static const String contractorServices = '$apiUrl/contractors/services';

  // Bid endpoints
  static const String bids = '$apiUrl/bids';
  static const String bidDetails = '$apiUrl/bids/';
  static const String createBid = '$apiUrl/bids';
  static const String updateBid = '$apiUrl/bids/';
  static const String deleteBid = '$apiUrl/bids/';

  // Service endpoints
  static const String services = '$apiUrl/services';
  static const String serviceDetails = '$apiUrl/services/';

  // Billing endpoints
  static const String subscription = '$baseUrl/api/billing/subscription';
  static const String paymentMethods = '$baseUrl/api/billing/payment-methods';
  static const String invoices = '$baseUrl/api/billing/invoices';

  static String contractorProfile(int contractorId) =>
      '$contractors/$contractorId';
  static String getStorageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl/storage/$path';
  }

  static String getAvatarUrl(String? path) => getStorageUrl(path);
  static String getPortfolioImageUrl(String? path) => getStorageUrl(path);
}
