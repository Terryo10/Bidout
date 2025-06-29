import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contractor_projects_bloc/contractor_projects_bloc.dart';
import '../../../constants/app_theme_extension.dart';
import '../../../models/projects/project_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/contractor_project_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state_widget.dart';
import 'project_detail_page.dart';

class BrowseProjectsPage extends StatefulWidget {
  const BrowseProjectsPage({super.key});

  @override
  State<BrowseProjectsPage> createState() => _BrowseProjectsPageState();
}

class _BrowseProjectsPageState extends State<BrowseProjectsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _selectedStatus = 'Available';
  String _selectedSortBy = 'created_at';
  String _selectedSortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ContractorProjectsBloc>().add(
          ContractorProjectsLoadRequested(
            status: _getApiStatus(_selectedStatus),
            sortBy: _selectedSortBy,
            sortOrder: _selectedSortOrder,
          ),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ContractorProjectsBloc>().add(
            ContractorProjectsLoadMoreRequested(
              search: _searchController.text.isEmpty
                  ? null
                  : _searchController.text,
              status: _getApiStatus(_selectedStatus),
              sortBy: _selectedSortBy,
              sortOrder: _selectedSortOrder,
            ),
          );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  String _getApiStatus(String displayStatus) {
    switch (displayStatus) {
      case 'Available':
        return 'request_for_bids_received,sourcing_of_vendors';
      case 'Open':
        return 'request_for_bids_received';
      case 'Sourcing':
        return 'sourcing_of_vendors';
      case 'Review':
        return 'bids_ready_for_approval';
      default:
        return 'request_for_bids_received,sourcing_of_vendors';
    }
  }

  void _onSearch() {
    context.read<ContractorProjectsBloc>().add(
          ContractorProjectsSearchRequested(
            query: _searchController.text,
            status: _getApiStatus(_selectedStatus),
            sortBy: _selectedSortBy,
            sortOrder: _selectedSortOrder,
          ),
        );
  }

  void _onRefresh() {
    context.read<ContractorProjectsBloc>().add(
          ContractorProjectsRefreshRequested(
            search:
                _searchController.text.isEmpty ? null : _searchController.text,
            status: _getApiStatus(_selectedStatus),
            sortBy: _selectedSortBy,
            sortOrder: _selectedSortOrder,
          ),
        );
  }

  void _onFilterChanged() {
    context.read<ContractorProjectsBloc>().add(
          ContractorProjectsLoadRequested(
            search:
                _searchController.text.isEmpty ? null : _searchController.text,
            status: _getApiStatus(_selectedStatus),
            sortBy: _selectedSortBy,
            sortOrder: _selectedSortOrder,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Available Projects',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: BlocBuilder<ContractorProjectsBloc, ContractorProjectsState>(
              builder: (context, state) {
                if (state is ContractorProjectsLoading &&
                    (state is! ContractorProjectsLoaded ||
                        (state as ContractorProjectsLoaded)
                            .projects
                            .data
                            .isEmpty)) {
                  return const LoadingIndicator();
                }

                if (state is ContractorProjectsError) {
                  return _buildErrorState(state.message);
                }

                if (state is ContractorProjectsLoaded) {
                  if (state.projects.data.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No Projects Available',
                      subtitle:
                          'There are no available projects matching your criteria at the moment.',
                      icon: Icons.work_outline,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.projects.data.length +
                          (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.projects.data.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: LoadingIndicator(),
                          );
                        }

                        final project = state.projects.data[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ContractorProjectCard(
                            project: project,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailPage(
                                  projectId: project.id,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _searchController,
            label: 'Search',
            hint: 'Search projects...',
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch();
                    },
                  )
                : const Icon(Icons.search),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Status',
                  _selectedStatus,
                  ['Available', 'Open', 'Sourcing', 'Review'],
                  (value) {
                    setState(() => _selectedStatus = value!);
                    _onFilterChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'Sort',
                  _selectedSortBy == 'created_at'
                      ? 'Date'
                      : _selectedSortBy == 'budget'
                          ? 'Budget'
                          : 'Title',
                  ['Date', 'Budget', 'Title'],
                  (value) {
                    setState(() {
                      _selectedSortBy = value == 'Date'
                          ? 'created_at'
                          : value == 'Budget'
                              ? 'budget'
                              : 'title';
                    });
                    _onFilterChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              _buildSortOrderButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true, // This prevents overflow
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.borderLight),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(
            option,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSortOrderButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSortOrder = _selectedSortOrder == 'desc' ? 'asc' : 'desc';
        });
        _onFilterChanged();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: context.borderLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _selectedSortOrder == 'desc'
              ? Icons.keyboard_arrow_down
              : Icons.keyboard_arrow_up,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onRefresh,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
