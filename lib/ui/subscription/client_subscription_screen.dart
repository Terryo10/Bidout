import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/subscription_bloc/subscription_bloc.dart';
import '../../models/subscription/subscription_package.dart';
import '../../models/subscription/user_subscription.dart';
import '../../constants/app_theme_extension.dart';

class ClientSubscriptionScreen extends StatefulWidget {
  const ClientSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<ClientSubscriptionScreen> createState() =>
      _ClientSubscriptionScreenState();
}

class _ClientSubscriptionScreenState extends State<ClientSubscriptionScreen> {
  List<SubscriptionPackage> _packages = [];

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(SubscriptionLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SubscriptionPaymentProcessing) {
            // Show loading dialog while preparing Stripe payment
            _showPaymentLoadingDialog(context);

            // Find the package being subscribed to
            String packageName = 'Subscription';
            double amount = 0.0;

            if (state.metadata != null &&
                state.metadata!['package_id'] != null) {
              try {
                final packageId =
                    int.parse(state.metadata!['package_id'].toString());
                final package = _packages.firstWhere(
                  (pkg) => pkg.id == packageId,
                  orElse: () => _packages.isNotEmpty
                      ? _packages.first
                      : SubscriptionPackage(
                          id: 0,
                          name: 'Unknown',
                          slug: '',
                          description: '',
                          price: 0.0,
                          billingPeriod: 'monthly',
                          features: [],
                          isActive: true,
                          isFeatured: false,
                          sortOrder: 0,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                );
                packageName = package.name;
                amount = package.price;
              } catch (e) {
                if (_packages.isNotEmpty) {
                  packageName = _packages.first.name;
                  amount = _packages.first.price;
                }
              }
            }

            // Trigger payment UI with a slight delay to show loading
            Future.delayed(const Duration(milliseconds: 500), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Close loading dialog
              }
              context.read<SubscriptionBloc>().add(
                    SubscriptionInitiatePayment(
                      clientSecret: state.clientSecret,
                      packageName: packageName,
                      amount: amount,
                      type: 'subscription',
                    ),
                  );
            });

            // Safety timeout to close dialog if something goes wrong
            Future.delayed(const Duration(seconds: 10), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            });
          } else if (state is SubscriptionSubscribed) {
            // Close any open dialogs
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully subscribed!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SubscriptionError &&
              state.message.contains('Payment')) {
            // Close loading dialog if payment error occurs
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          }
        },
        child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is SubscriptionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading subscription',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<SubscriptionBloc>()
                            .add(SubscriptionLoadRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimary,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is SubscriptionLoaded) {
              // Store packages for use during payment processing
              _packages = state.packages;
              return _buildSubscriptionContent(state);
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(SubscriptionLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.activeSubscription != null) ...[
            _buildCurrentSubscriptionCard(state.activeSubscription!),
            const SizedBox(height: 24),
          ],
          const Text(
            'Choose Your Plan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock premium features to get the most out of your projects',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ...state.packages
              .map((package) => _buildPackageCard(
                    package,
                    state.activeSubscription,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(UserSubscription subscription) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: subscription.isActive ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscription.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (subscription.isActive) ...[
              Text(
                'Expires in ${subscription.daysUntilExpiry} days',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Expires on: ${subscription.expiresAt.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (subscription.isActive && !subscription.isCancelled)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelSubscription(subscription.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                if (subscription.isCancelled)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _resumeSubscription(subscription.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Resume'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(
      SubscriptionPackage package, UserSubscription? activeSubscription) {
    final isCurrentPlan =
        activeSubscription?.subscriptionPackageId == package.id;

    return Card(
      elevation: package.isFeatured ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: package.isFeatured
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: Column(
          children: [
            if (package.isFeatured)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCurrentPlan)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        package.formattedPrice,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/${package.billingCycle}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Features
                  ...package.features
                      .map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),

                  const SizedBox(height: 20),

                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isCurrentPlan ? null : () => _subscribe(package.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: package.isFeatured
                            ? Theme.of(context).primaryColor
                            : null,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isCurrentPlan ? 'Current Plan' : 'Subscribe',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _subscribe(int packageId) {
    context.read<SubscriptionBloc>().add(
          SubscriptionSubscribeRequested(packageId: packageId),
        );
  }

  void _cancelSubscription(int subscriptionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content:
            const Text('Are you sure you want to cancel your subscription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SubscriptionBloc>().add(
                    SubscriptionCancelRequested(subscriptionId: subscriptionId),
                  );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _resumeSubscription(int subscriptionId) {
    context.read<SubscriptionBloc>().add(
          SubscriptionResumeRequested(subscriptionId: subscriptionId),
        );
  }

  void _showPaymentLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Preparing Payment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we set up your secure payment...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
