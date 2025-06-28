class Service {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}

class ContractorService {
  final int? id;
  final int contractorId;
  final int serviceId;
  final int experienceYears;
  final double? hourlyRate;
  final String? specializationNotes;
  final bool isPrimaryService;
  final Service? service;

  ContractorService({
    this.id,
    required this.contractorId,
    required this.serviceId,
    required this.experienceYears,
    this.hourlyRate,
    this.specializationNotes,
    required this.isPrimaryService,
    this.service,
  });

  factory ContractorService.fromJson(Map<String, dynamic> json) {
    return ContractorService(
      id: json['id'],
      contractorId: json['contractor_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      experienceYears: json['experience_years'] ?? 0,
      hourlyRate: json['hourly_rate'] != null
          ? double.tryParse(json['hourly_rate'].toString())
          : null,
      specializationNotes: json['specialization_notes'],
      isPrimaryService: json['is_primary_service'] ?? false,
      service:
          json['service'] != null ? Service.fromJson(json['service']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'contractor_id': contractorId,
      'service_id': serviceId,
      'experience_years': experienceYears,
      'hourly_rate': hourlyRate,
      'specialization_notes': specializationNotes,
      'is_primary_service': isPrimaryService,
      if (service != null) 'service': service!.toJson(),
    };
  }

  String get serviceName => service?.name ?? 'Unknown Service';
}

class Province {
  final int id;
  final String name;
  final String code;
  final String country;
  final bool isActive;

  Province({
    required this.id,
    required this.name,
    required this.code,
    required this.country,
    required this.isActive,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      country: json['country'] ?? 'ZA',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country,
      'is_active': isActive,
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final String? website;
  final List<String>? services;
  final List<String>? skills;
  final String? businessName;
  final String? licenseNumber;
  final String? experience;
  final List<String>? serviceAreas;
  final double? hourlyRate;
  final String? companyName;
  final String? position;
  final String? industry;
  final String userType;
  final List<String> availableRoles;
  final String activeRole;
  final bool isDualRole;
  final String? contractorStatus;
  final int freeBidsRemaining;
  final int totalFreeBidsGranted;
  final DateTime? freeBidsGrantedAt;
  final int purchasedBidsRemaining;
  final int totalBidsPurchased;
  final double? rating;
  final int? totalReviews;
  final bool isFeatured;
  final String? portfolioDescription;
  final List<String>? serviceSpecialties;
  final List<String>? certifications;
  final int? yearsExperience;
  final String? workPhilosophy;
  final List<String>? workAreas;
  final bool availableForHire;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> roles;
  final List<Province> provinces;
  final List<ContractorService> contractorServices;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.website,
    this.services,
    this.skills,
    this.businessName,
    this.licenseNumber,
    this.experience,
    this.serviceAreas,
    this.hourlyRate,
    this.companyName,
    this.position,
    this.industry,
    required this.userType,
    required this.availableRoles,
    required this.activeRole,
    required this.isDualRole,
    this.contractorStatus,
    required this.freeBidsRemaining,
    required this.totalFreeBidsGranted,
    this.freeBidsGrantedAt,
    required this.purchasedBidsRemaining,
    required this.totalBidsPurchased,
    this.rating,
    this.totalReviews,
    required this.isFeatured,
    this.portfolioDescription,
    this.serviceSpecialties,
    this.certifications,
    this.yearsExperience,
    this.workPhilosophy,
    this.workAreas,
    required this.availableForHire,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
    required this.provinces,
    required this.contractorServices,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] ?? 0,
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        avatar: json['avatar']?.toString(),
        bio: json['bio']?.toString(),
        website: json['website']?.toString(),
        services: json['services'] != null && json['services'] is List
            ? List<String>.from(json['services'].map((e) => e.toString()))
            : null,
        skills: json['skills'] != null && json['skills'] is List
            ? List<String>.from(json['skills'].map((e) => e.toString()))
            : null,
        businessName: json['business_name']?.toString(),
        licenseNumber: json['license_number']?.toString(),
        experience: json['experience']?.toString(),
        serviceAreas: json['service_areas'] != null &&
                json['service_areas'] is List
            ? List<String>.from(json['service_areas'].map((e) => e.toString()))
            : null,
        hourlyRate: json['hourly_rate'] != null
            ? double.tryParse(json['hourly_rate'].toString())
            : null,
        companyName: json['company_name']?.toString(),
        position: json['position']?.toString(),
        industry: json['industry']?.toString(),
        userType: json['user_type']?.toString() ?? 'client',
        availableRoles:
            json['available_roles'] != null && json['available_roles'] is List
                ? List<String>.from(
                    json['available_roles'].map((e) => e.toString()))
                : [],
        activeRole: json['active_role']?.toString() ??
            json['user_type']?.toString() ??
            'client',
        isDualRole: json['is_dual_role'] == true,
        contractorStatus: json['contractor_status']?.toString(),
        freeBidsRemaining:
            int.tryParse(json['free_bids_remaining']?.toString() ?? '0') ?? 0,
        totalFreeBidsGranted:
            int.tryParse(json['total_free_bids_granted']?.toString() ?? '0') ??
                0,
        freeBidsGrantedAt: json['free_bids_granted_at'] != null
            ? DateTime.tryParse(json['free_bids_granted_at'].toString())
            : null,
        purchasedBidsRemaining:
            int.tryParse(json['purchased_bids_remaining']?.toString() ?? '0') ??
                0,
        totalBidsPurchased:
            int.tryParse(json['total_bids_purchased']?.toString() ?? '0') ?? 0,
        rating: json['rating'] != null
            ? double.tryParse(json['rating'].toString())
            : null,
        totalReviews:
            int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
        isFeatured: json['is_featured'] == true,
        portfolioDescription: json['portfolio_description']?.toString(),
        serviceSpecialties: json['service_specialties'] != null &&
                json['service_specialties'] is List
            ? List<String>.from(
                json['service_specialties'].map((e) => e.toString()))
            : null,
        certifications: json['certifications'] != null &&
                json['certifications'] is List
            ? List<String>.from(json['certifications'].map((e) => e.toString()))
            : null,
        yearsExperience: json['years_experience'] != null
            ? int.tryParse(json['years_experience'].toString())
            : null,
        workPhilosophy: json['work_philosophy']?.toString(),
        workAreas: json['work_areas'] != null && json['work_areas'] is List
            ? List<String>.from(json['work_areas'].map((e) => e.toString()))
            : null,
        availableForHire: json['available_for_hire'] == true,
        emailVerifiedAt: json['email_verified_at'] != null
            ? DateTime.tryParse(json['email_verified_at'].toString())
            : null,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
            DateTime.now(),
        roles: json['roles'] != null && json['roles'] is List
            ? List<String>.from(json['roles'].map((role) => role is Map
                ? (role['name']?.toString() ?? '')
                : role.toString()))
            : [],
        provinces: json['provinces'] != null && json['provinces'] is List
            ? List<Province>.from(json['provinces']
                .where((p) => p is Map<String, dynamic>)
                .map((p) => Province.fromJson(p as Map<String, dynamic>)))
            : [],
        contractorServices: json['contractor_services'] != null &&
                json['contractor_services'] is List
            ? List<ContractorService>.from(json['contractor_services']
                .where((cs) => cs is Map<String, dynamic>)
                .map((cs) =>
                    ContractorService.fromJson(cs as Map<String, dynamic>)))
            : [],
      );
    } catch (e) {
      // Handle JSON parsing errors gracefully
      throw FormatException('Failed to parse UserModel from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'website': website,
      'services': services,
      'skills': skills,
      'business_name': businessName,
      'license_number': licenseNumber,
      'experience': experience,
      'service_areas': serviceAreas,
      'hourly_rate': hourlyRate,
      'company_name': companyName,
      'position': position,
      'industry': industry,
      'user_type': userType,
      'available_roles': availableRoles,
      'active_role': activeRole,
      'is_dual_role': isDualRole,
      'contractor_status': contractorStatus,
      'free_bids_remaining': freeBidsRemaining,
      'total_free_bids_granted': totalFreeBidsGranted,
      'free_bids_granted_at': freeBidsGrantedAt?.toIso8601String(),
      'purchased_bids_remaining': purchasedBidsRemaining,
      'total_bids_purchased': totalBidsPurchased,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_featured': isFeatured,
      'portfolio_description': portfolioDescription,
      'service_specialties': serviceSpecialties,
      'certifications': certifications,
      'years_experience': yearsExperience,
      'work_philosophy': workPhilosophy,
      'work_areas': workAreas,
      'available_for_hire': availableForHire,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'roles': roles,
      'provinces': provinces.map((p) => p.toJson()).toList(),
      'contractor_services':
          contractorServices.map((cs) => cs.toJson()).toList(),
    };
  }

  bool get isClient => activeRole == 'client';
  bool get isContractor => activeRole == 'contractor';
  bool get isAdmin => activeRole == 'admin';
  bool get isContractorApproved => contractorStatus == 'approved';
  bool get hasContractorRole => availableRoles.contains('contractor');
  bool get hasClientRole => availableRoles.contains('client');
  bool get canSubmitBids => freeBidsRemaining > 0 || purchasedBidsRemaining > 0;
  bool get canAccessContactInfo => hasActiveSubscription;
  bool get canDirectlyContactContractors =>
      hasClientRole && hasActiveSubscription;
  bool get canSendServiceRequests => hasClientRole;
  bool get canRespondToServiceRequests =>
      hasContractorRole && hasActiveSubscription;
  bool get hasActiveSubscription => userType != 'free';
}
