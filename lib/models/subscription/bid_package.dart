class BidPackage {
  final int id;
  final String name;
  final String description;
  final int bidsCount;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final bool isActive;
  final bool isFeatured;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  BidPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.bidsCount,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.isActive,
    required this.isFeatured,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BidPackage.fromJson(Map<String, dynamic> json) {
    return BidPackage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      bidsCount: json['bids_count'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      discountPercentage: json['discount_percentage'],
      isActive: json['is_active'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
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
      'description': description,
      'bids_count': bidsCount,
      'price': price,
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'is_active': isActive,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedOriginalPrice =>
      originalPrice != null ? '\$${originalPrice!.toStringAsFixed(2)}' : '';
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;
  double get pricePerBid => bidsCount > 0 ? price / bidsCount : 0.0;
  String get formattedPricePerBid => '\$${pricePerBid.toStringAsFixed(2)}';
}
