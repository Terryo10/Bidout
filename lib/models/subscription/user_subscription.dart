class UserSubscription {
  final int id;
  final int userId;
  final int subscriptionPackageId;
  final String? stripeSubscriptionId;
  final DateTime startsAt;
  final DateTime expiresAt;
  final String status; // 'active', 'cancelled', 'expired', 'pending'
  final String paymentStatus; // 'paid', 'pending', 'failed'
  final String? paymentMethod;
  final String? paymentId;
  final Map<String, dynamic>? metadata;
  final int bidsUsedCurrentPeriod;
  final DateTime? lastBidResetAt;
  final int totalResets;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.subscriptionPackageId,
    this.stripeSubscriptionId,
    required this.startsAt,
    required this.expiresAt,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentId,
    this.metadata,
    required this.bidsUsedCurrentPeriod,
    this.lastBidResetAt,
    required this.totalResets,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      subscriptionPackageId: json['subscription_package_id'] ?? 0,
      stripeSubscriptionId: json['stripe_subscription_id'],
      startsAt:
          DateTime.tryParse(json['starts_at'].toString()) ?? DateTime.now(),
      expiresAt:
          DateTime.tryParse(json['expires_at'].toString()) ?? DateTime.now(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      paymentId: json['payment_id'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      bidsUsedCurrentPeriod: json['bids_used_current_period'] ?? 0,
      lastBidResetAt: json['last_bid_reset_at'] != null
          ? DateTime.tryParse(json['last_bid_reset_at'].toString())
          : null,
      totalResets: json['total_resets'] ?? 0,
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
      'subscription_package_id': subscriptionPackageId,
      'stripe_subscription_id': stripeSubscriptionId,
      'starts_at': startsAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'payment_id': paymentId,
      'metadata': metadata,
      'bids_used_current_period': bidsUsedCurrentPeriod,
      'last_bid_reset_at': lastBidResetAt?.toIso8601String(),
      'total_resets': totalResets,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());
  bool get isExpired => expiresAt.isBefore(DateTime.now());
  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'pending';
  bool get isPaid => paymentStatus == 'paid';

  int get daysUntilExpiry {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }
}
