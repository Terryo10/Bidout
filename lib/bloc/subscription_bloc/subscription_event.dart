part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

// Load subscription data
class SubscriptionLoadRequested extends SubscriptionEvent {}

// Load subscription packages
class SubscriptionPackagesLoadRequested extends SubscriptionEvent {}

// Load bid packages (for contractors)
class BidPackagesLoadRequested extends SubscriptionEvent {}

// Subscribe to a package
class SubscriptionSubscribeRequested extends SubscriptionEvent {
  final int packageId;
  final String? paymentMethodId;

  const SubscriptionSubscribeRequested({
    required this.packageId,
    this.paymentMethodId,
  });

  @override
  List<Object?> get props => [packageId, paymentMethodId];
}

// Cancel subscription
class SubscriptionCancelRequested extends SubscriptionEvent {
  final int subscriptionId;

  const SubscriptionCancelRequested({required this.subscriptionId});

  @override
  List<Object?> get props => [subscriptionId];
}

// Resume subscription
class SubscriptionResumeRequested extends SubscriptionEvent {
  final int subscriptionId;

  const SubscriptionResumeRequested({required this.subscriptionId});

  @override
  List<Object?> get props => [subscriptionId];
}

// Update subscription
class SubscriptionUpdateRequested extends SubscriptionEvent {
  final int subscriptionId;
  final int newPackageId;

  const SubscriptionUpdateRequested({
    required this.subscriptionId,
    required this.newPackageId,
  });

  @override
  List<Object?> get props => [subscriptionId, newPackageId];
}

// Purchase bids
class BidPurchaseRequested extends SubscriptionEvent {
  final int packageId;
  final String? paymentMethodId;
  final String? promoCode;

  const BidPurchaseRequested({
    required this.packageId,
    this.paymentMethodId,
    this.promoCode,
  });

  @override
  List<Object?> get props => [packageId, paymentMethodId, promoCode];
}

// Load bid purchase history
class BidPurchaseHistoryLoadRequested extends SubscriptionEvent {}

// Payment success callback
class SubscriptionPaymentSucceeded extends SubscriptionEvent {
  final String paymentIntentId;
  final Map<String, dynamic>? metadata;

  const SubscriptionPaymentSucceeded({
    required this.paymentIntentId,
    this.metadata,
  });

  @override
  List<Object?> get props => [paymentIntentId, metadata];
}

// Payment failed callback
class SubscriptionPaymentFailed extends SubscriptionEvent {
  final String error;
  final Map<String, dynamic>? metadata;

  const SubscriptionPaymentFailed({
    required this.error,
    this.metadata,
  });

  @override
  List<Object?> get props => [error, metadata];
}

// Initiate payment UI
class SubscriptionInitiatePayment extends SubscriptionEvent {
  final String clientSecret;
  final String packageName;
  final double amount;
  final String type; // 'subscription' or 'bids'

  const SubscriptionInitiatePayment({
    required this.clientSecret,
    required this.packageName,
    required this.amount,
    required this.type,
  });

  @override
  List<Object?> get props => [clientSecret, packageName, amount, type];
}
