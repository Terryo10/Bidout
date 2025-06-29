import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bids_bloc/bids_bloc.dart';
import '../../../constants/app_theme_extension.dart';
import '../../../models/bids/bid_model.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/bid_card.dart';
import 'widgets/bid_filter_sheet.dart';

@RoutePage()
class ContractorBidsPage extends StatefulWidget {
  const ContractorBidsPage({super.key});

  @override
  State<ContractorBidsPage> createState() => _ContractorBidsPageState();
}

class _ContractorBidsPageState extends State<ContractorBidsPage> {
  final ScrollController _scrollController = ScrollController();
  String? _statusFilter;
  String? _searchQuery;

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
    context.read<BidsBloc>().add(ContractorBidsLoadRequested(
          status: _statusFilter,
          search: _searchQuery,
        ));
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<BidsBloc>().add(const ContractorBidsLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onRefresh() {
    context.read<BidsBloc>().add(const ContractorBidsRefreshRequested());
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BidFilterSheet(
        currentStatus: _statusFilter,
        currentSearch: _searchQuery,
        onFiltersApplied: (status, search) {
          setState(() {
            _statusFilter = status;
            _searchQuery = search;
          });
          _loadBids();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'My Bids',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
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

          if (state is ContractorBidsLoaded) {
            final bids = state.bids.data;

            if (bids.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async => _onRefresh(),
              child: Column(
                children: [
                  _buildStatsHeader(context, bids),
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
                        return BidCard(
                          bid: bid,
                          onTap: () => _navigateToBidDetails(bid),
                          onEdit: bid.canBeEdited ? () => _editBid(bid) : null,
                          onWithdraw: bid.canBeWithdrawn
                              ? () => _withdrawBid(bid)
                              : null,
                        );
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

  Widget _buildStatsHeader(BuildContext context, List<BidModel> bids) {
    final pendingCount = bids.where((b) => b.isPending).length;
    final acceptedCount = bids.where((b) => b.isAccepted).length;
    final rejectedCount = bids.where((b) => b.isRejected).length;

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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Pending',
              pendingCount.toString(),
              context.warning,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              context,
              'Accepted',
              acceptedCount.toString(),
              context.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              context,
              'Rejected',
              rejectedCount.toString(),
              context.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
            'Start bidding on projects to see them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToBidDetails(BidModel bid) {
    // Navigate to bid details page
    // This would be implemented with your routing system
  }

  void _editBid(BidModel bid) {
    // Navigate to edit bid page
    // This would be implemented with your routing system
  }

  void _withdrawBid(BidModel bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Bid'),
        content: const Text(
          'Are you sure you want to withdraw this bid? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BidsBloc>().add(BidDeleteRequested(
                    projectId: bid.projectId,
                    bidId: bid.id,
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.error,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
