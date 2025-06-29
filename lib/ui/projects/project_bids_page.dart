import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/bids_bloc/bids_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/bids/bid_model.dart';
import '../../models/projects/project_model.dart';
import '../widgets/custom_app_bar.dart';

@RoutePage()
class ProjectBidsPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectBidsPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectBidsPage> createState() => _ProjectBidsPageState();
}

class _ProjectBidsPageState extends State<ProjectBidsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBids();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadBids() {
    context.read<BidsBloc>().add(ProjectBidsLoadRequested(
          projectId: widget.project.id,
        ));
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<BidsBloc>().add(ProjectBidsLoadMoreRequested(
            projectId: widget.project.id,
          ));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onRefresh() {
    context.read<BidsBloc>().add(ProjectBidsRefreshRequested(
          projectId: widget.project.id,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Project Bids',
        showBackButton: true,
      ),
      body: BlocBuilder<BidsBloc, BidsState>(
        builder: (context, state) {
          if (state is BidsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BidsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBids,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProjectBidsLoaded &&
              state.projectId == widget.project.id) {
            final bids = state.bids.data;

            if (bids.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async => _onRefresh(),
              child: Column(
                children: [
                  _buildProjectInfo(context),
                  _buildBidsHeader(context, bids),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: bids.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= bids.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final bid = bids[index];
                        return _buildBidCard(context, bid);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Budget: R${NumberFormat('#,##0.00').format(widget.project.budget)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.project.service?.name != null)
            Text(
              widget.project.service!.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildBidsHeader(BuildContext context, List<BidModel> bids) {
    final sortedBids = List<BidModel>.from(bids)
      ..sort((a, b) => a.amount.compareTo(b.amount));

    final lowestBid = sortedBids.isNotEmpty ? sortedBids.first.amount : 0.0;
    final averageBid = bids.isNotEmpty
        ? bids.map((b) => b.amount).reduce((a, b) => a + b) / bids.length
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBidStat(
              context,
              'Total Bids',
              bids.length.toString(),
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBidStat(
              context,
              'Lowest Bid',
              bids.isNotEmpty
                  ? 'R${NumberFormat('#,##0').format(lowestBid)}'
                  : '-',
              context.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBidStat(
              context,
              'Average Bid',
              bids.isNotEmpty
                  ? 'R${NumberFormat('#,##0').format(averageBid)}'
                  : '-',
              context.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidStat(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBidCard(BuildContext context, BidModel bid) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
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
                        bid.contractor?.name ?? 'Contractor',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      if (bid.contractor?.rating != null &&
                          bid.contractor!.rating > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: context.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bid.contractor!.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${bid.contractor!.totalReviews})',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: context.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildBidStatus(context, bid),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBidInfo(
                    context,
                    'Bid Amount',
                    'R${NumberFormat('#,##0.00').format(bid.amount)}',
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBidInfo(
                    context,
                    'Timeline',
                    '${bid.timeline} days',
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Proposal',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              bid.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Submitted ${_formatDate(bid.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                ),
                const Spacer(),
                if (bid.isPending) ...[
                  OutlinedButton(
                    onPressed: () => _rejectBid(bid),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.error,
                      side: BorderSide(color: context.error),
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _acceptBid(bid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.success,
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidStatus(BuildContext context, BidModel bid) {
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

  Widget _buildBidInfo(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: context.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Bids Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Contractors haven\'t submitted any bids for this project yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  void _acceptBid(BidModel bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Bid'),
        content: Text(
          'Are you sure you want to accept this bid of R${NumberFormat('#,##0.00').format(bid.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement bid acceptance logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bid acceptance functionality coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.success,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _rejectBid(BidModel bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Bid'),
        content: const Text(
          'Are you sure you want to reject this bid?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement bid rejection logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bid rejection functionality coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
