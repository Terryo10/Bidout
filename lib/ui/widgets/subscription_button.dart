import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../subscription/subscription_page.dart';

class SubscriptionButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool showIcon;
  final VoidCallback? onPressed;

  const SubscriptionButton({
    Key? key,
    this.text,
    this.icon,
    this.showIcon = true,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final user = state.user;
        final defaultText =
            user.isContractor ? 'Manage Subscription & Bids' : 'Upgrade Plan';
        final defaultIcon =
            user.isContractor ? Icons.credit_card : Icons.upgrade;

        return ElevatedButton.icon(
          onPressed: onPressed ?? () => _navigateToSubscription(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: showIcon
              ? Icon(icon ?? defaultIcon, size: 18)
              : const SizedBox.shrink(),
          label: Text(
            text ?? defaultText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  void _navigateToSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SubscriptionPage(),
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final user = state.user;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      user.isContractor ? Icons.construction : Icons.business,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.isContractor ? 'Contractor Plan' : 'Client Plan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (user.isContractor) ...[
                  _buildBidInfo(context, user),
                  const SizedBox(height: 12),
                ],
                Text(
                  user.isContractor
                      ? 'Manage your subscription and purchase additional bids'
                      : 'Upgrade your plan to unlock premium features',
                  style: TextStyle(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SubscriptionButton(
                    text: user.isContractor ? 'Manage Plan' : 'View Plans',
                    showIcon: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBidInfo(BuildContext context, dynamic user) {
    final totalBids = user.freeBidsRemaining + user.purchasedBidsRemaining;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.gavel,
            color: context.colors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$totalBids Bids Available',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: context.colors.primary,
            ),
          ),
          const Spacer(),
          Text(
            '${user.freeBidsRemaining} free • ${user.purchasedBidsRemaining} purchased',
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
