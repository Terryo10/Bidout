// lib/models/contractor/contractor_service_model.dart
import '../services/service_model.dart';

class ContractorServiceModel {
  final int id;
  final int contractorId;
  final int serviceId;
  final double hourlyRate;
  final int experienceYears;
  final String? specializationNotes;
  final bool isPrimaryService;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ServiceModel? service;

  ContractorServiceModel({
    required this.id,
    required this.contractorId,
    required this.serviceId,
    required this.hourlyRate,
    required this.experienceYears,
    this.specializationNotes,
    required this.isPrimaryService,
    required this.createdAt,
    required this.updatedAt,
    this.service,
  });

  factory ContractorServiceModel.fromJson(Map<String, dynamic> json) {
    return ContractorServiceModel(
      id: json['id'] ?? 0,
      contractorId: json['contractor_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      hourlyRate: json['hourly_rate'] != null
          ? double.parse(json['hourly_rate'].toString())
          : 0.0,
      experienceYears: json['experience_years'] ?? 0,
      specializationNotes: json['specialization_notes'],
      isPrimaryService: json['is_primary_service'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractor_id': contractorId,
      'service_id': serviceId,
      'hourly_rate': hourlyRate,
      'experience_years': experienceYears,
      'specialization_notes': specializationNotes,
      'is_primary_service': isPrimaryService,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'service': service?.toJson(),
    };
  }
}
