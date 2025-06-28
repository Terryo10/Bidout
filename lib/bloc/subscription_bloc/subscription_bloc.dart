import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/subscription/subscription_package.dart';
import '../../models/subscription/user_subscription.dart';
import '../../models/subscription/bid_package.dart';
import '../../models/subscription/bid_purchase.dart';
import '../../repositories/subscription_repo/subscription_repository.dart';
import '../../services/stripe_service.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;

  SubscriptionBloc({required this.subscriptionRepository})
      : super(SubscriptionInitial()) {
    on<SubscriptionLoadRequested>(_onSubscriptionLoadRequested);
    on<SubscriptionPackagesLoadRequested>(_onSubscriptionPackagesLoadRequested);
    on<BidPackagesLoadRequested>(_onBidPackagesLoadRequested);
    on<SubscriptionSubscribeRequested>(_onSubscriptionSubscribeRequested);
    on<SubscriptionCancelRequested>(_onSubscriptionCancelRequested);
    on<SubscriptionResumeRequested>(_onSubscriptionResumeRequested);
    on<SubscriptionUpdateRequested>(_onSubscriptionUpdateRequested);
    on<BidPurchaseRequested>(_onBidPurchaseRequested);
    on<BidPurchaseHistoryLoadRequested>(_onBidPurchaseHistoryLoadRequested);
    on<SubscriptionPaymentSucceeded>(_onSubscriptionPaymentSucceeded);
    on<SubscriptionPaymentFailed>(_onSubscriptionPaymentFailed);
    on<SubscriptionInitiatePayment>(_onSubscriptionInitiatePayment);
  }

  Future<void> _onSubscriptionLoadRequested(
    SubscriptionLoadRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    try {
      final packages = await subscriptionRepository.getSubscriptionPackages();
      final activeSubscription =
          await subscriptionRepository.getActiveSubscription();
      final bidPackages = await subscriptionRepository.getBidPackages();
      final bidPurchaseHistory =
          await subscriptionRepository.getBidPurchaseHistory();
      final bidStatus = await subscriptionRepository.getBidStatus();

      emit(SubscriptionLoaded(
        packages: packages,
        activeSubscription: activeSubscription,
        bidPackages: bidPackages,
        bidPurchaseHistory: bidPurchaseHistory,
        bidStatus: bidStatus,
      ));
    } catch (e) {
      emit(SubscriptionError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onSubscriptionPackagesLoadRequested(
    SubscriptionPackagesLoadRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      try {
        final packages = await subscriptionRepository.getSubscriptionPackages();
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(packages: packages));
      } catch (e) {
        emit(SubscriptionError(message: _getErrorMessage(e)));
      }
    } else {
      if (!isClosed) {
        add(SubscriptionLoadRequested());
      }
    }
  }

  Future<void> _onBidPackagesLoadRequested(
    BidPackagesLoadRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      try {
        final bidPackages = await subscriptionRepository.getBidPackages();
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(bidPackages: bidPackages));
      } catch (e) {
        emit(SubscriptionError(message: _getErrorMessage(e)));
      }
    } else {
      if (!isClosed) {
        add(SubscriptionLoadRequested());
      }
    }
  }

  Future<void> _onSubscriptionSubscribeRequested(
    SubscriptionSubscribeRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionSubscribing(packageId: event.packageId));

    try {
      final result = await subscriptionRepository.subscribeToPackage(
        event.packageId,
        paymentMethodId: event.paymentMethodId,
      );

      if (result.containsKey('client_secret')) {
        // Payment required
        emit(SubscriptionPaymentProcessing(
          clientSecret: result['client_secret'],
          paymentIntentId: result['payment_intent_id'],
          metadata: result,
        ));
      } else if (result.containsKey('subscription')) {
        // Subscription created successfully
        final subscription = UserSubscription.fromJson(result['subscription']);
        emit(SubscriptionSubscribed(subscription: subscription));
        // Refresh data
        if (!isClosed) {
          add(SubscriptionLoadRequested());
        }
      }
    } catch (e) {
      emit(SubscriptionError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onSubscriptionCancelRequested(
    SubscriptionCancelRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionCancelling(subscriptionId: event.subscriptionId));

    try {
      final subscription =
          await subscriptionRepository.cancelSubscription(event.subscriptionId);
      emit(SubscriptionCancelled(subscription: subscription));
      // Refresh data
      if (!isClosed) {
        add(SubscriptionLoadRequested());
      }
    } catch (e) {
      emit(SubscriptionError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onSubscriptionResumeRequested(
    SubscriptionResumeRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    try {
      final subscription =
          await subscriptionRepository.resumeSubscription(event.subscriptionId);
      emit(SubscriptionSubscribed(subscription: subscription));
      // Refresh data
      if (!isClosed) {
        add(SubscriptionLoadRequested());
      }
    } catch (e) {
      emit(SubscriptionError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onSubscriptionUpdateRequested(
    SubscriptionUpdateRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    try {
      final subscription = await subscriptionRepository.updateSubscription(
        event.subscriptionId,
        event.newPackageId,
      );
      emit(SubscriptionSubscribed(subscription: subscription));
      // Refresh data
      if (!isClosed) {
        add(SubscriptionLoadRequested());
      }
    } catch (e) {
      emit(SubscriptionError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onBidPurchaseRequested(
    BidPurchaseRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(BidPurchasing(packageId: event.packageId));

    try {
      final result = await subscriptionRepository.purchaseBids(
        event.packageId,
        paymentMethodId: event.paymentMethodId,
        promoCode: event.promoCode,
      );

      if (result.containsKey('client_secret')) {
        // Payment required
        emit(SubscriptionPaymentProcessing(
          clientSecret: result['client_secret'],
          paymentIntentId: result['payment_intent_id'],
          metadata: result,
        ));
      } else if (result.containsKey('bid_purchase')) {
        // Purchase completed successfully
        final purchase = BidPurchase.fromJson(result['bid_purchase']);
        emit(BidPurchased(purchase: purchase));
        // Refresh data
        if (!isClosed) {
          add(SubscriptionLoadRequested());
        }
      }
    } catch (e) {
      emit(SubscriptionError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onBidPurchaseHistoryLoadRequested(
    BidPurchaseHistoryLoadRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      try {
        final bidPurchaseHistory =
            await subscriptionRepository.getBidPurchaseHistory();
        final currentState = state as SubscriptionLoaded;
        emit(currentState.copyWith(bidPurchaseHistory: bidPurchaseHistory));
      } catch (e) {
        emit(SubscriptionError(message: _getErrorMessage(e)));
      }
    }
  }

  Future<void> _onSubscriptionPaymentSucceeded(
    SubscriptionPaymentSucceeded event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await subscriptionRepository.confirmPayment(event.paymentIntentId);

      // Emit success state with payment details
      if (event.metadata != null) {
        emit(PaymentSuccessful(
          type: event.metadata!['type'] ?? 'subscription',
          packageName: event.metadata!['packageName'] ?? 'Package',
          amount: event.metadata!['amount']?.toDouble() ?? 0.0,
          bidCount: event.metadata!['bidCount'],
          details: event.metadata,
        ));
      } else {
        // Fallback: refresh data to get updated subscription/bid status
        if (!isClosed) {
          add(SubscriptionLoadRequested());
        }
      }
    } catch (e) {
      emit(SubscriptionError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onSubscriptionPaymentFailed(
    SubscriptionPaymentFailed event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionError(message: event.error));
  }

  Future<void> _onSubscriptionInitiatePayment(
    SubscriptionInitiatePayment event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      bool paymentSucceeded = false;

      if (event.type == 'subscription') {
        paymentSucceeded = await StripeService.showSubscriptionPaymentSheet(
          clientSecret: event.clientSecret,
          packageName: event.packageName,
          amount: event.amount,
        );
      } else if (event.type == 'bids') {
        paymentSucceeded = await StripeService.showBidPurchasePaymentSheet(
          clientSecret: event.clientSecret,
          packageName: event.packageName,
          amount: event.amount,
          bidCount: 0, // You might want to pass this from the event
        );
      }

      if (paymentSucceeded) {
        final paymentIntentId =
            StripeService.getPaymentIntentFromClientSecret(event.clientSecret);
        if (!isClosed) {
          add(SubscriptionPaymentSucceeded(
            paymentIntentId: paymentIntentId,
            metadata: {
              'type': event.type,
              'packageName': event.packageName,
              'amount': event.amount,
              'bidCount': event.type == 'bids'
                  ? 0
                  : null, // This should be passed from the event if available
            },
          ));
        }
      } else {
        if (!isClosed) {
          add(const SubscriptionPaymentFailed(
            error: 'Payment was cancelled or failed',
          ));
        }
      }
    } catch (e) {
      if (!isClosed) {
        add(SubscriptionPaymentFailed(
          error: 'Payment error: ${e.toString()}',
        ));
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiErrorModel) {
      return error.firstError;
    }
    return error.toString();
  }
}
