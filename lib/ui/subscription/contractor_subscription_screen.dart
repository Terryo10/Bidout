import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/subscription_bloc/subscription_bloc.dart';
import '../../models/subscription/subscription_package.dart';
import '../../models/subscription/user_subscription.dart';
import '../../models/subscription/bid_package.dart';
import '../../constants/app_theme_extension.dart';

class ContractorSubscriptionScreen extends StatefulWidget {
  const ContractorSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<ContractorSubscriptionScreen> createState() =>
      _ContractorSubscriptionScreenState();
}

class _ContractorSubscriptionScreenState
    extends State<ContractorSubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SubscriptionPackage> _packages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<SubscriptionBloc>().add(SubscriptionLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription & Bids'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Subscription Plans'),
            Tab(text: 'Buy Bids'),
          ],
        ),
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

            // Determine if this is subscription or bid payment
            String packageName = 'Payment';
            double amount = 0.0;
            String type = 'subscription';

            if (state.metadata != null) {
              if (state.metadata!['type'] == 'bid_purchase') {
                type = 'bids';
                packageName = state.metadata!['package_name'] ?? 'Bid Package';
                amount = double.tryParse(
                        state.metadata!['amount']?.toString() ?? '0') ??
                    0.0;
              } else {
                type = 'subscription';
                if (state.metadata!['package_id'] != null &&
                    _packages.isNotEmpty) {
                  try {
                    final packageId =
                        int.parse(state.metadata!['package_id'].toString());
                    final package = _packages.firstWhere(
                      (pkg) => pkg.id == packageId,
                      orElse: () => _packages.first,
                    );
                    packageName = package.name;
                    amount = package.price;
                  } catch (e) {
                    packageName = _packages.first.name;
                    amount = _packages.first.price;
                  }
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
                      type: type,
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
          } else if (state is BidPurchased) {
            // Close any open dialogs
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bids purchased successfully!'),
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
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildSubscriptionTab(state),
                  _buildBidPurchaseTab(state),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionTab(SubscriptionLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bid Status Card
          _buildBidStatusCard(state.bidStatus),
          const SizedBox(height: 24),

          if (state.activeSubscription != null) ...[
            _buildCurrentSubscriptionCard(state.activeSubscription!),
            const SizedBox(height: 24),
          ],

          const Text(
            'Subscription Plans',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a plan to unlock premium features and get more bids',
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

  Widget _buildBidPurchaseTab(SubscriptionLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bid Status Card
          _buildBidStatusCard(state.bidStatus),
          const SizedBox(height: 24),

          const Text(
            'Buy Bids',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Purchase additional bids to submit more proposals',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          ...state.bidPackages
              .map((package) => _buildBidPackageCard(package))
              .toList(),

          if (state.bidPurchaseHistory.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text(
              'Purchase History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...state.bidPurchaseHistory
                .take(5)
                .map((purchase) => _buildPurchaseHistoryCard(purchase))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildBidStatusCard(Map<String, dynamic>? bidStatus) {
    if (bidStatus == null) return const SizedBox.shrink();

    final freeBids = bidStatus['free_bids_remaining'] ?? 0;
    final purchasedBids = bidStatus['purchased_bids_remaining'] ?? 0;
    final totalBids = freeBids + purchasedBids;

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
          children: [
            const Text(
              'Your Bids',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child:
                      _buildBidCounter('Total Bids', totalBids, Colors.white),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white38,
                ),
                Expanded(
                  child:
                      _buildBidCounter('Free Bids', freeBids, Colors.white70),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white38,
                ),
                Expanded(
                  child: _buildBidCounter(
                      'Purchased', purchasedBids, Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidCounter(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
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
            const SizedBox(height: 12),
            if (subscription.isActive) ...[
              Text(
                'Expires in ${subscription.daysUntilExpiry} days',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Renewal Date: ${subscription.expiresAt.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
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
        child: Padding(
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
                  if (package.isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'POPULAR',
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

              // Price and bid limit
              Row(
                children: [
                  Text(
                    package.formattedPrice,
                    style: const TextStyle(
                      fontSize: 28,
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
                  const Spacer(),
                  if (package.bidLimit != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${package.bidLimit} bids/month',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
      ),
    );
  }

  Widget _buildBidPackageCard(BidPackage package) {
    return Card(
      elevation: package.isFeatured ? 6 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: package.isFeatured
              ? Border.all(color: Colors.orange, width: 2)
              : null,
        ),
        child: Padding(
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (package.hasDiscount)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${package.discountPercentage}% OFF',
                        style: const TextStyle(
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
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${package.bidsCount} Bids',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        package.formattedPricePerBid + ' per bid',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (package.hasDiscount) ...[
                        Text(
                          package.formattedOriginalPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        package.formattedPrice,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _purchaseBids(package.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: package.isFeatured
                        ? Colors.orange
                        : Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Buy ${package.bidsCount} Bids',
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
      ),
    );
  }

  Widget _buildPurchaseHistoryCard(dynamic purchase) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            Icons.shopping_cart,
            color: Colors.green,
            size: 20,
          ),
        ),
        title: Text('${purchase.bidsPurchased} Bids'),
        subtitle: Text(
            purchase.purchasedAt?.toLocal().toString().split(' ')[0] ?? ''),
        trailing: Text(
          purchase.formattedAmount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _subscribe(int packageId) {
    context.read<SubscriptionBloc>().add(
          SubscriptionSubscribeRequested(packageId: packageId),
        );
  }

  void _purchaseBids(int packageId) {
    context.read<SubscriptionBloc>().add(
          BidPurchaseRequested(packageId: packageId),
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
