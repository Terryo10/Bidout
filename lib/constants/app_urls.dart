// lib/constants/app_urls.dart
class AppUrls {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String apiUrl = '$baseUrl/api';

  // Auth endpoints
  static const String login = '$apiUrl/login';
  static const String register = '$apiUrl/register';
  static const String forgotPassword = '$apiUrl/forgot-password';
  static const String resetPassword = '$apiUrl/reset-password';
  static const String verifyEmail = '$apiUrl/verify-email';
  static const String resendVerification = '$apiUrl/resend-verification';
  static const String logout = '$apiUrl/logout';
  static const String me = '$apiUrl/me';

  // Google Auth endpoints
  static const String googleAuth = '$apiUrl/auth/google';

  // User endpoints
  static const String profile = '$apiUrl/user/profile';
  static const String updateProfile = '$apiUrl/user/profile';
  static const String updateAvatar = '$apiUrl/user/avatar';
  static const String changePassword = '$apiUrl/user/password';
  static const String getRoleInfo = '$apiUrl/user/role/info';
  static const String switchRole = '$apiUrl/user/role/switch';
  static const String enableRole = '$apiUrl/user/role/enable';

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
  static const String contractorProjects = '$apiUrl/contractor/projects';

  // Bid endpoints
  static const String projectBids =
      '$apiUrl/projects/'; // projects/{project}/bids
  static const String contractorBids =
      '$apiUrl/contractor/bids'; // Need to add to backend
  static const String createBid =
      '$apiUrl/projects/'; // projects/{project}/bids
  static const String updateBid =
      '$apiUrl/projects/'; // projects/{project}/bids/{bid}
  static const String deleteBid =
      '$apiUrl/projects/'; // projects/{project}/bids/{bid}

  // Service endpoints
  static const String services = '$apiUrl/services';
  static const String serviceDetails = '$apiUrl/services/';

  // Service Request endpoints
  static const String serviceRequests = '$apiUrl/service-requests';
  static const String serviceRequestDetails = '$apiUrl/service-requests/';
  static const String updateServiceRequestStatus = '$apiUrl/service-requests/';

  // Billing endpoints
  static const String subscription = '$baseUrl/api/billing/subscription';
  static const String paymentMethods = '$baseUrl/api/billing/payment-methods';
  static const String invoices = '$baseUrl/api/billing/invoices';

  // Subscription endpoints
  static const String subscriptionPackages = '$apiUrl/subscription-packages';
  static const String userSubscription = '$apiUrl/subscription';
  static const String subscribe = '$apiUrl/subscribe';
  static const String cancelSubscription = '$apiUrl/subscription/{id}/cancel';
  static const String resumeSubscription = '$apiUrl/subscription/{id}/resume';
  static const String updateSubscription = '$apiUrl/subscription/{id}';

  // Bid package endpoints
  static const String bidPackages = '$apiUrl/bid-packages';
  static const String bidStatus = '$apiUrl/bid-status';
  static const String buyBids = '$apiUrl/buy-bids';
  static const String bidPurchases = '$apiUrl/bid-purchases';
  static const String confirmPayment = '$apiUrl/confirm-payment';

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
