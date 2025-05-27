
// lib/models/contractor/contractor_service_model.dart
import '../projects/project_model.dart';

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


