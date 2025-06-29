import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_theme_extension.dart';
import '../../../../models/bids/bid_model.dart';

class BidCard extends StatelessWidget {
  final BidModel bid;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onWithdraw;

  const BidCard({
    super.key,
    required this.bid,
    this.onTap,
    this.onEdit,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bid.project?.title ?? 'Project',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (bid.project?.service?.name != null)
                          Text(
                            bid.project!.service!.name,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.textSecondary,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Your Bid',
                      'R${NumberFormat('#,##0.00').format(bid.amount)}',
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      'Timeline',
                      '${bid.timeline} days',
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
              if (bid.project?.budget != null) ...[
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Client Budget',
                  'R${NumberFormat('#,##0.00').format(bid.project!.budget)}',
                  Icons.account_balance_wallet_outlined,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted ${_formatDate(bid.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  if (onEdit != null || onWithdraw != null)
                    _buildActionMenu(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (bid.status.toLowerCase()) {
      case 'accepted':
        backgroundColor = context.success.withOpacity(0.1);
        textColor = context.success;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        backgroundColor = context.error.withOpacity(0.1);
        textColor = context.error;
        icon = Icons.cancel;
        break;
      default: // pending
        backgroundColor = context.warning.withOpacity(0.1);
        textColor = context.warning;
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            bid.statusDisplayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: context.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: context.textSecondary,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'withdraw':
            onWithdraw?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 12),
                Text('Edit Bid'),
              ],
            ),
          ),
        if (onWithdraw != null)
          PopupMenuItem(
            value: 'withdraw',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: context.error),
                const SizedBox(width: 12),
                Text('Withdraw', style: TextStyle(color: context.error)),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
