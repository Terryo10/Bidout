import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load current user profile
class ProfileLoadRequested extends ProfileEvent {}

// Update profile data
class ProfileUpdateRequested extends ProfileEvent {
  final Map<String, dynamic> profileData;

  ProfileUpdateRequested({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

// Update avatar
class ProfileAvatarUpdateRequested extends ProfileEvent {
  final String imagePath;

  ProfileAvatarUpdateRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

// Reset profile state
class ProfileReset extends ProfileEvent {}

// Refresh profile data
class ProfileRefreshRequested extends ProfileEvent {}

// Update contractor-specific fields
class ContractorProfileUpdateRequested extends ProfileEvent {
  final Map<String, dynamic> contractorData;

  ContractorProfileUpdateRequested({required this.contractorData});

  @override
  List<Object?> get props => [contractorData];
}

// Update client-specific fields
class ClientProfileUpdateRequested extends ProfileEvent {
  final Map<String, dynamic> clientData;

  ClientProfileUpdateRequested({required this.clientData});

  @override
  List<Object?> get props => [clientData];
}

// Update services for contractor
class ContractorServicesUpdateRequested extends ProfileEvent {
  final List<Map<String, dynamic>> services;

  ContractorServicesUpdateRequested({required this.services});

  @override
  List<Object?> get props => [services];
}

// Update skills for contractor
class ContractorSkillsUpdateRequested extends ProfileEvent {
  final List<String> skills;

  ContractorSkillsUpdateRequested({required this.skills});

  @override
  List<Object?> get props => [skills];
}

// Update certifications for contractor
class ContractorCertificationsUpdateRequested extends ProfileEvent {
  final List<String> certifications;

  ContractorCertificationsUpdateRequested({required this.certifications});

  @override
  List<Object?> get props => [certifications];
}
