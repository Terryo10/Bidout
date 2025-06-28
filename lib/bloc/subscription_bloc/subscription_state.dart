part of 'subscription_bloc.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionPackage> packages;
  final UserSubscription? activeSubscription;
  final List<BidPackage> bidPackages;
  final List<BidPurchase> bidPurchaseHistory;
  final Map<String, dynamic>? bidStatus;

  const SubscriptionLoaded({
    required this.packages,
    this.activeSubscription,
    required this.bidPackages,
    required this.bidPurchaseHistory,
    this.bidStatus,
  });

  @override
  List<Object?> get props => [
        packages,
        activeSubscription,
        bidPackages,
        bidPurchaseHistory,
        bidStatus,
      ];

  SubscriptionLoaded copyWith({
    List<SubscriptionPackage>? packages,
    UserSubscription? activeSubscription,
    List<BidPackage>? bidPackages,
    List<BidPurchase>? bidPurchaseHistory,
    Map<String, dynamic>? bidStatus,
  }) {
    return SubscriptionLoaded(
      packages: packages ?? this.packages,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      bidPackages: bidPackages ?? this.bidPackages,
      bidPurchaseHistory: bidPurchaseHistory ?? this.bidPurchaseHistory,
      bidStatus: bidStatus ?? this.bidStatus,
    );
  }
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Specific states for operations
class SubscriptionSubscribing extends SubscriptionState {
  final int packageId;

  const SubscriptionSubscribing({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}

class SubscriptionSubscribed extends SubscriptionState {
  final UserSubscription subscription;

  const SubscriptionSubscribed({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionCancelling extends SubscriptionState {
  final int subscriptionId;

  const SubscriptionCancelling({required this.subscriptionId});

  @override
  List<Object?> get props => [subscriptionId];
}

class SubscriptionCancelled extends SubscriptionState {
  final UserSubscription subscription;

  const SubscriptionCancelled({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class BidPurchasing extends SubscriptionState {
  final int packageId;

  const BidPurchasing({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}

class BidPurchased extends SubscriptionState {
  final BidPurchase purchase;

  const BidPurchased({required this.purchase});

  @override
  List<Object?> get props => [purchase];
}

class SubscriptionPaymentProcessing extends SubscriptionState {
  final String clientSecret;
  final String? paymentIntentId;
  final Map<String, dynamic>? metadata;

  const SubscriptionPaymentProcessing({
    required this.clientSecret,
    this.paymentIntentId,
    this.metadata,
  });

  @override
  List<Object?> get props => [clientSecret, paymentIntentId, metadata];
}
