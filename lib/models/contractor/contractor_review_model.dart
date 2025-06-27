class ContractorReviewModel {
  final int id;
  final int contractorId;
  final int clientId;
  final int? projectId;
  final double rating;
  final String reviewText;
  final Map<String, dynamic>? ratingBreakdown;
  final bool isVerified;
  final bool isFeatured;
  final DateTime completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String clientName;
  final String? projectTitle;

  ContractorReviewModel({
    required this.id,
    required this.contractorId,
    required this.clientId,
    this.projectId,
    required this.rating,
    required this.reviewText,
    this.ratingBreakdown,
    required this.isVerified,
    required this.isFeatured,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.clientName,
    this.projectTitle,
  });

  factory ContractorReviewModel.fromJson(Map<String, dynamic> json) {
    return ContractorReviewModel(
      id: json['id'],
      contractorId: json['contractor_id'],
      clientId: json['client_id'],
      projectId: json['project_id'],
      rating: double.parse(json['rating'].toString()),
      reviewText: json['review_text'] ?? '',
      ratingBreakdown: json['rating_breakdown'] != null
          ? Map<String, dynamic>.from(json['rating_breakdown'])
          : null,
      isVerified: json['is_verified'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      completedAt: DateTime.parse(json['completed_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      clientName: json['client']['name'] ?? 'Anonymous',
      projectTitle: json['project']?['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractor_id': contractorId,
      'client_id': clientId,
      'project_id': projectId,
      'rating': rating,
      'review_text': reviewText,
      'rating_breakdown': ratingBreakdown,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'completed_at': completedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDate {
    return '${completedAt.day}/${completedAt.month}/${completedAt.year}';
  }

  String get starsDisplay {
    return '★' * rating.floor() + '☆' * (5 - rating.floor());
  }
}
