// lib/constants/app_urls.dart
class AppUrls {
  static const String baseUrl = 'https://api.bidout.com/api';
  
  // Auth endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String forgotPassword = '$baseUrl/forgot-password';
  static const String resetPassword = '$baseUrl/reset-password';
  static const String logout = '$baseUrl/logout';
  static const String me = '$baseUrl/me';
  
  // User endpoints
  static const String userProfile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile';
  static const String updateAvatar = '$baseUrl/user/avatar';
  
  // Project endpoints
  static const String projects = '$baseUrl/projects';
  
  // Contractor endpoints
  static const String contractors = '$baseUrl/contractors';
  
  // Billing endpoints
  static const String subscription = '$baseUrl/billing/subscription';
  static const String paymentMethods = '$baseUrl/billing/payment-methods';
  static const String invoices = '$baseUrl/billing/invoices';
}