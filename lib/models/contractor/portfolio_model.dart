// lib/models/contractor/portfolio_model.dart
import 'portfolio_image_model.dart';

class PortfolioModel {
  final int id;
  final int contractorId;
  final String title;
  final String? description;
  final String? projectType;
  final DateTime? completionDate;
  final double? projectValue;
  final String? clientName;
  final String? clientTestimonial;
  final List<String> tags;
  final bool isFeatured;
  final int sortOrder;
  final List<PortfolioImageModel> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  PortfolioModel({
    required this.id,
    required this.contractorId,
    required this.title,
    this.description,
    this.projectType,
    this.completionDate,
    this.projectValue,
    this.clientName,
    this.clientTestimonial,
    this.tags = const [],
    required this.isFeatured,
    required this.sortOrder,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'],
      contractorId: json['contractor_id'],
      title: json['title'],
      description: json['description'],
      projectType: json['project_type'],
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      projectValue: json['project_value'] != null
          ? double.parse(json['project_value'].toString())
          : null,
      clientName: json['client_name'],
      clientTestimonial: json['client_testimonial'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isFeatured: json['is_featured'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((image) => PortfolioImageModel.fromJson(image))
              .toList()
          : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractor_id': contractorId,
      'title': title,
      'description': description,
      'project_type': projectType,
      'completion_date': completionDate?.toIso8601String(),
      'project_value': projectValue,
      'client_name': clientName,
      'client_testimonial': clientTestimonial,
      'tags': tags,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
      'images': images.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedValue {
    if (projectValue == null) return 'Value not disclosed';
    return '\$${projectValue!.toStringAsFixed(0)}';
  }

  String get formattedDate {
    if (completionDate == null) return 'Date not specified';
    return '${completionDate!.day}/${completionDate!.month}/${completionDate!.year}';
  }

  PortfolioImageModel? get primaryImage {
    return images.where((img) => img.isPrimary).firstOrNull ??
        (images.isNotEmpty ? images.first : null);
  }

  List<PortfolioImageModel> get beforeImages {
    return images.where((img) => img.isBeforeImage).toList();
  }

  List<PortfolioImageModel> get afterImages {
    return images.where((img) => !img.isBeforeImage).toList();
  }
}
