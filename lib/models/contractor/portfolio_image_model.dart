// lib/models/contractor/portfolio_image_model.dart
class PortfolioImageModel {
  final int id;
  final int portfolioId;
  final String imagePath;
  final String? caption;
  final bool isBeforeImage;
  final bool isPrimary;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  PortfolioImageModel({
    required this.id,
    required this.portfolioId,
    required this.imagePath,
    this.caption,
    required this.isBeforeImage,
    required this.isPrimary,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PortfolioImageModel.fromJson(Map<String, dynamic> json) {
    return PortfolioImageModel(
      id: json['id'],
      portfolioId: json['portfolio_id'],
      imagePath: json['image_path'],
      caption: json['caption'],
      isBeforeImage: json['is_before_image'] ?? false,
      isPrimary: json['is_primary'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'portfolio_id': portfolioId,
      'image_path': imagePath,
      'caption': caption,
      'is_before_image': isBeforeImage,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get imageUrl {
    return 'http://127.0.0.1:8000/storage/$imagePath';
  }
}
