// lib/models/project_model.dart
import '../services/service_model.dart';

class ProjectModel {
  final int id;
  final int? serviceId;
  final int clientId;
  final String title;
  final String description;
  final String? street;
  final String? city;
  final String? zipCode;
  final int? provinceId;
  final double? lat;
  final double? lng;
  final double budget;
  final String frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String keyFactor;
  final String status;
  final String? additionalRequirements;
  final bool isDrafted;
  final int? contractorId;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ServiceModel? service;
  final List<ProjectImageModel> images;

  ProjectModel({
    required this.id,
    this.serviceId,
    required this.clientId,
    required this.title,
    required this.description,
    this.street,
    this.city,
    this.zipCode,
    this.provinceId,
    this.lat,
    this.lng,
    required this.budget,
    required this.frequency,
    this.startDate,
    this.endDate,
    required this.keyFactor,
    required this.status,
    this.additionalRequirements,
    required this.isDrafted,
    this.contractorId,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.images = const [],
  });

  bool isInBidPhase() {
    return [
      'request_for_bids_received',
      'sourcing_of_vendors',
      'bids_ready_for_approval'
    ].contains(status.toLowerCase());
  }

  bool isInProgress() {
    return status.toLowerCase() == 'project_in_progress';
  }

  bool isCompleted() {
    return status.toLowerCase() == 'project_completed';
  }

  bool isScheduled() {
    return status.toLowerCase() == 'project_being_scheduled';
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      serviceId: json['service_id'],
      clientId: json['client_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      street: json['street'],
      city: json['city'],
      zipCode: json['zip_code'],
      provinceId: json['province_id'],
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.parse(json['lng'].toString()) : null,
      budget: double.parse(json['budget'].toString()),
      frequency: json['frequency'] ?? 'One-time',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      keyFactor: json['key_factor'] ?? 'quality',
      status: json['status'] ?? 'request_for_bids_received',
      additionalRequirements: json['additionalRequirements'],
      isDrafted: json['is_drafted'] ?? false,
      contractorId: json['contractor_id'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((i) => ProjectImageModel.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'client_id': clientId,
      'title': title,
      'description': description,
      'street': street,
      'city': city,
      'zip_code': zipCode,
      'province_id': provinceId,
      'lat': lat,
      'lng': lng,
      'budget': budget,
      'frequency': frequency,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'key_factor': keyFactor,
      'status': status,
      'additionalRequirements': additionalRequirements,
      'is_drafted': isDrafted,
      'contractor_id': contractorId,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'service': service?.toJson(),
      'images': images.map((i) => i.toJson()).toList(),
    };
  }
}

// lib/models/project_image_model.dart
class ProjectImageModel {
  final int id;
  final int projectId;
  final String path;
  final String? caption;
  final bool isPrimary;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectImageModel({
    required this.id,
    required this.projectId,
    required this.path,
    this.caption,
    required this.isPrimary,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectImageModel.fromJson(Map<String, dynamic> json) {
    return ProjectImageModel(
      id: json['id'],
      projectId: json['project_id'],
      path: json['path'],
      caption: json['caption'],
      isPrimary: json['is_primary'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'path': path,
      'caption': caption,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// lib/models/service_model.dart
class ServiceModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// lib/models/project_request_model.dart
class ProjectRequestModel {
  final String title;
  final String description;
  final String? additionalRequirements;
  final double budget;
  final String frequency;
  final String keyFactor;
  final DateTime startDate;
  final DateTime endDate;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final int serviceId;
  final List<String> images;
  final bool isDrafted;

  ProjectRequestModel({
    required this.title,
    required this.description,
    this.additionalRequirements,
    required this.budget,
    required this.frequency,
    required this.keyFactor,
    required this.startDate,
    required this.endDate,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    required this.serviceId,
    required this.images,
    required this.isDrafted,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'additionalRequirements': additionalRequirements,
      'budget': budget,
      'frequency': frequency,
      'key_factor': keyFactor,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'service_id': serviceId,
      'images': images,
      'is_drafted': isDrafted,
    };
  }
}
