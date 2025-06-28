import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user_model.dart';
import 'profile_provider.dart';

class ProfileRepository {
  final FlutterSecureStorage storage;
  final ProfileProvider profileProvider;

  ProfileRepository({
    required this.storage,
    required this.profileProvider,
  });

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      return await profileProvider.getCurrentUserProfile();
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update general profile
  Future<UserModel?> updateProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final updatedUser = await profileProvider.updateProfile(
        profileData: profileData,
      );

      // Update any cached user data if needed
      if (updatedUser != null) {
        // You could save updated user data to local storage here if needed
        // await _cacheUserData(updatedUser);
      }

      return updatedUser;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update avatar
  Future<UserModel?> updateAvatar({
    required String imagePath,
  }) async {
    try {
      final updatedUser = await profileProvider.updateAvatar(
        imagePath: imagePath,
      );

      // Update any cached user data if needed
      if (updatedUser != null) {
        // You could save updated user data to local storage here if needed
        // await _cacheUserData(updatedUser);
      }

      return updatedUser;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update contractor-specific profile
  Future<UserModel?> updateContractorProfile({
    required Map<String, dynamic> contractorData,
  }) async {
    try {
      final updatedUser = await profileProvider.updateContractorProfile(
        contractorData: contractorData,
      );

      if (updatedUser != null) {
        // Cache updated user data
        // await _cacheUserData(updatedUser);
      }

      return updatedUser;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update client-specific profile
  Future<UserModel?> updateClientProfile({
    required Map<String, dynamic> clientData,
  }) async {
    try {
      final updatedUser = await profileProvider.updateClientProfile(
        clientData: clientData,
      );

      if (updatedUser != null) {
        // Cache updated user data
        // await _cacheUserData(updatedUser);
      }

      return updatedUser;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update contractor services
  Future<UserModel?> updateContractorServices({
    required List<Map<String, dynamic>> services,
  }) async {
    try {
      final updatedUser = await profileProvider.updateContractorServices(
        services: services,
      );

      if (updatedUser != null) {
        // Cache updated user data
        // await _cacheUserData(updatedUser);
      }

      return updatedUser;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update contractor skills
  Future<UserModel?> updateContractorSkills({
    required List<String> skills,
  }) async {
    try {
      final updatedUser = await profileProvider.updateContractorSkills(
        skills: skills,
      );

      if (updatedUser != null) {
        // Cache updated user data
        // await _cacheUserData(updatedUser);
      }

      return updatedUser;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update contractor certifications
  Future<UserModel?> updateContractorCertifications({
    required List<String> certifications,
  }) async {
    try {
      final updatedUser = await profileProvider.updateContractorCertifications(
        certifications: certifications,
      );

      if (updatedUser != null) {
        // Cache updated user data
        // await _cacheUserData(updatedUser);
      }

      return updatedUser;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  // Helper method to cache user data (can be implemented if needed)
  // Future<void> _cacheUserData(UserModel user) async {
  //   try {
  //     await storage.write(
  //       key: 'cached_user_profile',
  //       value: json.encode(user.toJson()),
  //     );
  //   } catch (error) {
  //     // Silently fail for caching errors
  //   }
  // }

  // Helper method to get cached user data (can be implemented if needed)
  // Future<UserModel?> getCachedUserProfile() async {
  //   try {
  //     final cachedData = await storage.read(key: 'cached_user_profile');
  //     if (cachedData != null) {
  //       return UserModel.fromJson(json.decode(cachedData));
  //     }
  //     return null;
  //   } catch (error) {
  //     return null;
  //   }
  // }

  // Clear any cached profile data
  Future<void> clearProfileCache() async {
    try {
      await storage.delete(key: 'cached_user_profile');
    } catch (error) {
      // Silently fail for cache clearing errors
    }
  }
}
