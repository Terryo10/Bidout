// lib/models/contractor/contractor_model.dart
import '../services/service_model.dart';
import 'portfolio_model.dart';

class ContractorModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? businessName;
  final String? bio;
  final String? website;
  final String? licenseNumber;
  final int? yearsExperience;
  final double? hourlyRate;
  final double rating;
  final int totalReviews;
  final bool isFeatured;
  final bool availableForHire;
  final String? portfolioDescription;
  final List<String>? serviceAreas;
  final List<String>? skills;
  final List<String>? certifications;
  final String? workPhilosophy;
  final List<ContractorServiceModel> services;
  final List<PortfolioModel> featuredPortfolios;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContractorModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.businessName,
    this.bio,
    this.website,
    this.licenseNumber,
    this.yearsExperience,
    this.hourlyRate,
    required this.rating,
    required this.totalReviews,
    required this.isFeatured,
    required this.availableForHire,
    this.portfolioDescription,
    this.serviceAreas,
    this.skills,
    this.certifications,
    this.workPhilosophy,
    required this.services,
    required this.featuredPortfolios,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContractorModel.fromJson(Map<String, dynamic> json) {
    return ContractorModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      businessName: json['business_name'],
      bio: json['bio'],
      website: json['website'],
      licenseNumber: json['license_number'],
      yearsExperience: json['years_experience'],
      hourlyRate: json['hourly_rate'] != null
          ? double.parse(json['hourly_rate'].toString())
          : null,
      rating: double.parse(json['rating']?.toString() ?? '0'),
      totalReviews: json['total_reviews'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      availableForHire: json['available_for_hire'] ?? true,
      portfolioDescription: json['portfolio_description'],
      serviceAreas: json['service_areas'] != null
          ? List<String>.from(json['service_areas'])
          : null,
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : null,
      workPhilosophy: json['work_philosophy'],
      services: json['contractor_services'] != null
          ? (json['contractor_services'] as List)
              .map((s) => ContractorServiceModel.fromJson(s))
              .toList()
          : [],
      featuredPortfolios: json['featured_portfolios'] != null
          ? (json['featured_portfolios'] as List)
              .map((p) => PortfolioModel.fromJson(p))
              .toList()
          : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'business_name': businessName,
      'bio': bio,
      'website': website,
      'license_number': licenseNumber,
      'years_experience': yearsExperience,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_featured': isFeatured,
      'available_for_hire': availableForHire,
      'portfolio_description': portfolioDescription,
      'service_areas': serviceAreas,
      'skills': skills,
      'certifications': certifications,
      'work_philosophy': workPhilosophy,
      'contractor_services': services.map((s) => s.toJson()).toList(),
      'featured_portfolios': featuredPortfolios.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName =>
      businessName?.isNotEmpty == true ? businessName! : name;

  String get ratingDisplay {
    if (rating == 0 || totalReviews == 0) {
      return 'No ratings yet';
    }
    return '${rating.toStringAsFixed(1)}/5.0 ($totalReviews reviews)';
  }

  List<String> get primaryServices {
    return services
        .where((s) => s.isPrimaryService)
        .map((s) => s.service?.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
}

// lib/models/contractor/contractor_service_model.dart
class ContractorServiceModel {
  final int id;
  final int contractorId;
  final int serviceId;
  final int experienceYears;
  final double? hourlyRate;
  final String? specializationNotes;
  final bool isPrimaryService;
  final ServiceModel? service;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContractorServiceModel({
    required this.id,
    required this.contractorId,
    required this.serviceId,
    required this.experienceYears,
    this.hourlyRate,
    this.specializationNotes,
    required this.isPrimaryService,
    this.service,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContractorServiceModel.fromJson(Map<String, dynamic> json) {
    return ContractorServiceModel(
      id: json['id'],
      contractorId: json['contractor_id'],
      serviceId: json['service_id'],
      experienceYears: json['experience_years'] ?? 0,
      hourlyRate: json['hourly_rate'] != null
          ? double.parse(json['hourly_rate'].toString())
          : null,
      specializationNotes: json['specialization_notes'],
      isPrimaryService: json['is_primary_service'] ?? false,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractor_id': contractorId,
      'service_id': serviceId,
      'experience_years': experienceYears,
      'hourly_rate': hourlyRate,
      'specialization_notes': specializationNotes,
      'is_primary_service': isPrimaryService,
      'service': service?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

