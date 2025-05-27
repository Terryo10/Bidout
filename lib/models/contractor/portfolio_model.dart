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
  final List<String>? tags;
  final bool isFeatured;
  final int sortOrder;
  final List<PortfolioImageModel> images;
  final PortfolioImageModel? primaryImage;
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
    this.tags,
    required this.isFeatured,
    required this.sortOrder,
    required this.images,
    this.primaryImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'],
      contractorId: json['contractor_id'],
      title: json['title'] ?? '',
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
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isFeatured: json['is_featured'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((i) => PortfolioImageModel.fromJson(i))
              .toList()
          : [],
      primaryImage: json['primary_image'] != null
          ? PortfolioImageModel.fromJson(json['primary_image'])
          : null,
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
      'primary_image': primaryImage?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String? get primaryImageUrl {
    if (primaryImage != null) {
      return 'http://127.0.0.1:8000/storage/${primaryImage!.imagePath}';
    }
    if (images.isNotEmpty) {
      return 'http://127.0.0.1:8000/storage/${images.first.imagePath}';
    }
    return null;
  }
}

