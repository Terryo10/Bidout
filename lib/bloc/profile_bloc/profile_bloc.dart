import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/profile_repo/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileAvatarUpdateRequested>(_onProfileAvatarUpdateRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
    on<ProfileReset>(_onProfileReset);
    on<ContractorProfileUpdateRequested>(_onContractorProfileUpdateRequested);
    on<ClientProfileUpdateRequested>(_onClientProfileUpdateRequested);
    on<ContractorServicesUpdateRequested>(_onContractorServicesUpdateRequested);
    on<ContractorSkillsUpdateRequested>(_onContractorSkillsUpdateRequested);
    on<ContractorCertificationsUpdateRequested>(
        _onContractorCertificationsUpdateRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());

      final user = await profileRepository.getCurrentUserProfile();

      if (user != null) {
        emit(ProfileLoaded(user: user));
      } else {
        emit(ProfileError(message: 'Failed to load profile'));
      }
    } on SocketException {
      emit(ProfileNetworkError());
    } catch (error) {
      emit(ProfileError(
        message: error.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileUpdating());

      final updatedUser = await profileRepository.updateProfile(
        profileData: event.profileData,
      );

      if (updatedUser != null) {
        emit(ProfileUpdated(user: updatedUser));
        // Also emit ProfileLoaded to maintain consistency
        emit(ProfileLoaded(user: updatedUser));
      } else {
        emit(ProfileUpdateError(message: 'Failed to update profile'));
      }
    } on SocketException {
      emit(ProfileNetworkError());
    } catch (error) {
      final errorMessage = error.toString().replaceAll('Exception: ', '');

      // Check if it's a validation error
      if (errorMessage.contains('validation') || errorMessage.contains('422')) {
        try {
          // Try to parse validation errors if available
          emit(ProfileValidationError(errors: {'general': errorMessage}));
        } catch (_) {
          emit(ProfileUpdateError(message: errorMessage));
        }
      } else {
        emit(ProfileUpdateError(message: errorMessage));
      }
    }
  }

  Future<void> _onProfileAvatarUpdateRequested(
    ProfileAvatarUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileAvatarUploading());

      final updatedUser = await profileRepository.updateAvatar(
        imagePath: event.imagePath,
      );

      if (updatedUser != null) {
        emit(ProfileAvatarUpdated(user: updatedUser));
        // Also emit ProfileLoaded to maintain consistency
        emit(ProfileLoaded(user: updatedUser));
      } else {
        emit(ProfileAvatarUploadError(message: 'Failed to update avatar'));
      }
    } on SocketException {
      emit(ProfileNetworkError());
    } catch (error) {
      emit(ProfileAvatarUploadError(
        message: error.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Simply reload the profile
    add(ProfileLoadRequested());
  }

  Future<void> _onProfileReset(
    ProfileReset event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileInitial());
  }

  Future<void> _onContractorProfileUpdateRequested(
    ContractorProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileUpdating());

      final updatedUser = await profileRepository.updateContractorProfile(
        contractorData: event.contractorData,
      );

      if (updatedUser != null) {
        emit(ProfileUpdated(
          user: updatedUser,
          message: 'Contractor profile updated successfully',
        ));
        emit(ProfileLoaded(user: updatedUser));
      } else {
        emit(
            ProfileUpdateError(message: 'Failed to update contractor profile'));
      }
    } on SocketException {
      emit(ProfileNetworkError());
    } catch (error) {
      final errorMessage = error.toString().replaceAll('Exception: ', '');
      emit(ProfileUpdateError(message: errorMessage));
    }
  }

  Future<void> _onClientProfileUpdateRequested(
    ClientProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileUpdating());

      final updatedUser = await profileRepository.updateClientProfile(
        clientData: event.clientData,
      );

      if (updatedUser != null) {
        emit(ProfileUpdated(
          user: updatedUser,
          message: 'Client profile updated successfully',
        ));
        emit(ProfileLoaded(user: updatedUser));
      } else {
        emit(ProfileUpdateError(message: 'Failed to update client profile'));
      }
    } on SocketException {
      emit(ProfileNetworkError());
    } catch (error) {
      final errorMessage = error.toString().replaceAll('Exception: ', '');
      emit(ProfileUpdateError(message: errorMessage));
    }
  }

  Future<void> _onContractorServicesUpdateRequested(
    ContractorServicesUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileUpdating());

      final updatedUser = await profileRepository.updateContractorServices(
        services: event.services,
      );

      if (updatedUser != null) {
        emit(ProfileUpdated(
          user: updatedUser,
          message: 'Services updated successfully',
        ));
        emit(ProfileLoaded(user: updatedUser));
      } else {
        emit(ProfileUpdateError(message: 'Failed to update services'));
      }
    } on SocketException {
      emit(ProfileNetworkError());
    } catch (error) {
      final errorMessage = error.toString().replaceAll('Exception: ', '');
      emit(ProfileUpdateError(message: errorMessage));
    }
  }

  Future<void> _onContractorSkillsUpdateRequested(
    ContractorSkillsUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileUpdating());

      final updatedUser = await profileRepository.updateContractorSkills(
        skills: event.skills,
      );

      if (updatedUser != null) {
        emit(ProfileUpdated(
          user: updatedUser,
          message: 'Skills updated successfully',
        ));
        emit(ProfileLoaded(user: updatedUser));
      } else {
        emit(ProfileUpdateError(message: 'Failed to update skills'));
      }
    } on SocketException {
      emit(ProfileNetworkError());
    } catch (error) {
      final errorMessage = error.toString().replaceAll('Exception: ', '');
      emit(ProfileUpdateError(message: errorMessage));
    }
  }

  Future<void> _onContractorCertificationsUpdateRequested(
    ContractorCertificationsUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileUpdating());

      final updatedUser =
          await profileRepository.updateContractorCertifications(
        certifications: event.certifications,
      );

      if (updatedUser != null) {
        emit(ProfileUpdated(
          user: updatedUser,
          message: 'Certifications updated successfully',
        ));
        emit(ProfileLoaded(user: updatedUser));
      } else {
        emit(ProfileUpdateError(message: 'Failed to update certifications'));
      }
    } on SocketException {
      emit(ProfileNetworkError());
    } catch (error) {
      final errorMessage = error.toString().replaceAll('Exception: ', '');
      emit(ProfileUpdateError(message: errorMessage));
    }
  }
}
