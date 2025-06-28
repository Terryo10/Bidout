class BidPurchase {
  final int id;
  final int userId;
  final int bidsPurchased;
  final double amountPaid;
  final String currency;
  final String? paymentMethod;
  final String paymentStatus; // 'completed', 'pending', 'failed'
  final String? stripePaymentIntentId;
  final Map<String, dynamic>? metadata;
  final DateTime? purchasedAt;
  final String? promoCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  BidPurchase({
    required this.id,
    required this.userId,
    required this.bidsPurchased,
    required this.amountPaid,
    required this.currency,
    this.paymentMethod,
    required this.paymentStatus,
    this.stripePaymentIntentId,
    this.metadata,
    this.purchasedAt,
    this.promoCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BidPurchase.fromJson(Map<String, dynamic> json) {
    return BidPurchase(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bidsPurchased: json['bids_purchased'] ?? 0,
      amountPaid: double.tryParse(json['amount_paid'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'USD',
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'] ?? 'pending',
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      purchasedAt: json['purchased_at'] != null
          ? DateTime.tryParse(json['purchased_at'].toString())
          : null,
      promoCode: json['promo_code'],
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bids_purchased': bidsPurchased,
      'amount_paid': amountPaid,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'metadata': metadata,
      'purchased_at': purchasedAt?.toIso8601String(),
      'promo_code': promoCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCompleted => paymentStatus == 'completed';
  bool get isPending => paymentStatus == 'pending';
  bool get isFailed => paymentStatus == 'failed';
  String get formattedAmount => '\$${amountPaid.toStringAsFixed(2)}';
  double get pricePerBid =>
      bidsPurchased > 0 ? amountPaid / bidsPurchased : 0.0;
}
