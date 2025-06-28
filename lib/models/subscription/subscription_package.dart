class SubscriptionPackage {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final String billingPeriod; // 'monthly', 'yearly'
  final List<String> features;
  final bool isActive;
  final bool isFeatured;
  final int sortOrder;
  final int? bidLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPackage({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.billingPeriod,
    required this.features,
    required this.isActive,
    required this.isFeatured,
    required this.sortOrder,
    this.bidLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    // Handle features - can be either array of strings or array of objects from relationship
    List<String> parseFeatures(dynamic featuresData) {
      if (featuresData == null) return [];

      if (featuresData is List) {
        return featuresData.map((item) {
          if (item is String) {
            return item;
          } else if (item is Map<String, dynamic> && item['feature'] != null) {
            // Handle relationship format: {"id": 1, "feature": "Feature name"}
            return item['feature'].toString();
          }
          return item.toString();
        }).toList();
      }

      return [];
    }

    return SubscriptionPackage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      billingPeriod: json['billing_period'] ?? 'monthly',
      features: parseFeatures(json['features']),
      isActive: json['is_active'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      bidLimit: json['bid_limit'],
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'billing_period': billingPeriod,
      'features': features,
      'is_active': isActive,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
      'bid_limit': bidLimit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isMonthly => billingPeriod == 'monthly';
  bool get isYearly => billingPeriod == 'yearly';
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get billingCycle => isMonthly ? 'month' : 'year';
}
