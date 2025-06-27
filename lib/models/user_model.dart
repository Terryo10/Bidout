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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      website: json['website'],
      services:
          json['services'] != null ? List<String>.from(json['services']) : null,
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      businessName: json['business_name'],
      licenseNumber: json['license_number'],
      experience: json['experience']?.toString(),
      serviceAreas: json['service_areas'] != null
          ? List<String>.from(json['service_areas'])
          : null,
      hourlyRate: json['hourly_rate'] != null
          ? double.tryParse(json['hourly_rate'].toString()) ?? 0.0
          : null,
      companyName: json['company_name'],
      position: json['position'],
      industry: json['industry'],
      userType: json['user_type'] ?? 'client',
      availableRoles: json['available_roles'] != null
          ? List<String>.from(json['available_roles'])
          : [],
      activeRole: json['active_role'] ?? json['user_type'] ?? 'client',
      isDualRole: json['is_dual_role'] ?? false,
      contractorStatus: json['contractor_status'],
      freeBidsRemaining: json['free_bids_remaining'] ?? 0,
      totalFreeBidsGranted: json['total_free_bids_granted'] ?? 0,
      freeBidsGrantedAt: json['free_bids_granted_at'] != null
          ? DateTime.tryParse(json['free_bids_granted_at'].toString())
          : null,
      purchasedBidsRemaining: json['purchased_bids_remaining'] ?? 0,
      totalBidsPurchased: json['total_bids_purchased'] ?? 0,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : null,
      totalReviews: json['total_reviews'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      portfolioDescription: json['portfolio_description'],
      serviceSpecialties: json['service_specialties'] != null
          ? List<String>.from(json['service_specialties'])
          : null,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : null,
      yearsExperience: json['years_experience'],
      workPhilosophy: json['work_philosophy'],
      workAreas: json['work_areas'] != null
          ? List<String>.from(json['work_areas'])
          : null,
      availableForHire: json['available_for_hire'] ?? true,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
      roles: json['roles'] != null
          ? (json['roles'] is List
              ? List<String>.from(json['roles']
                  .map((role) => role is Map ? role['name'] : role.toString()))
              : [])
          : [],
    );
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
