// lib/ui/projects/project_listing_page.dart (Updated with Pagination)
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/projects_bloc/project_bloc.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/pagination/pagination_model.dart';
import '../../models/projects/project_model.dart';
import '../../routes/app_router.dart';
import '../widgets/project_card.dart';
import '../widgets/project_filter_widget.dart';

@RoutePage()
class ProjectListingPage extends StatefulWidget {
  const ProjectListingPage({super.key});

  @override
  State<ProjectListingPage> createState() => _ProjectListingPageState();
}

class _ProjectListingPageState extends State<ProjectListingPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  String? _currentSearchQuery;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProjects() {
    context.read<ProjectBloc>().add(ProjectLoadRequested(
          search: _currentSearchQuery,
          status: _selectedFilter != 'All'
              ? _mapFilterToStatus(_selectedFilter)
              : null,
          sortBy: _mapSortToField(_selectedSort),
          sortOrder: _mapSortToOrder(_selectedSort),
        ));
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<ProjectBloc>().state;
      if (currentState is ProjectLoaded && !currentState.hasReachedMax) {
        context.read<ProjectBloc>().add(ProjectLoadMoreRequested(
              search: _currentSearchQuery,
              status: _selectedFilter != 'All'
                  ? _mapFilterToStatus(_selectedFilter)
                  : null,
              sortBy: _mapSortToField(_selectedSort),
              sortOrder: _mapSortToOrder(_selectedSort),
            ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentSearchQuery = query.isNotEmpty ? query : null;
    });
    _debounceSearch();
  }

  void _debounceSearch() {
    // Simple debounce - in production, use a proper debounce implementation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ProjectBloc>().add(ProjectSearchRequested(
              query: _currentSearchQuery ?? '',
              status: _selectedFilter != 'All'
                  ? _mapFilterToStatus(_selectedFilter)
                  : null,
              sortBy: _mapSortToField(_selectedSort),
              sortOrder: _mapSortToOrder(_selectedSort),
            ));
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadProjects();
  }

  void _onSortChanged(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _loadProjects();
  }

  void _onRefresh() {
    context.read<ProjectBloc>().add(ProjectRefreshRequested(
          search: _currentSearchQuery,
          status: _selectedFilter != 'All'
              ? _mapFilterToStatus(_selectedFilter)
              : null,
          sortBy: _mapSortToField(_selectedSort),
          sortOrder: _mapSortToOrder(_selectedSort),
        ));
  }

  String? _mapFilterToStatus(String filter) {
    switch (filter) {
      case 'Open for Bids':
        return 'request_for_bids_received';
      case 'In Progress':
        return 'project_in_progress';
      case 'Completed':
        return 'project_completed';
      case 'Scheduled':
        return 'project_being_scheduled';
      default:
        return null;
    }
  }

  String? _mapSortToField(String sort) {
    switch (sort) {
      case 'Newest':
      case 'Oldest':
        return 'created_at';
      case 'Budget (High to Low)':
      case 'Budget (Low to High)':
        return 'budget';
      case 'Title A-Z':
        return 'title';
      default:
        return 'created_at';
    }
  }

  String? _mapSortToOrder(String sort) {
    switch (sort) {
      case 'Newest':
      case 'Budget (High to Low)':
        return 'desc';
      case 'Oldest':
      case 'Budget (Low to High)':
      case 'Title A-Z':
        return 'asc';
      default:
        return 'desc';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.router.push(CreateProjectRoute());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: context.colors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search projects...',
                    prefixIcon:
                        Icon(Icons.search, color: context.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon:
                                Icon(Icons.clear, color: context.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: context.colors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: context.colors.surfaceContainer,
                  ),
                ),
                const SizedBox(height: 16),

                // Filter and Sort Row
                Row(
                  children: [
                    Expanded(
                      child: ProjectFilterWidget(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: _onFilterChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSortDropdown(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // Projects List
          Expanded(
            child: BlocConsumer<ProjectBloc, ProjectState>(
              listener: (context, state) {
                if (state is ProjectError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProjectLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ProjectLoaded) {
                  final projects = state.projects.data;

                  if (projects.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _onRefresh();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          projects.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= projects.length) {
                          // Loading indicator for pagination
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final project = projects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProjectCard(
                            project: project,
                            onTap: () {
                              context.router.push(
                                  ProjectViewRoute(projectId: project.id));
                            },
                          ),
                        );
                      },
                    ),
                  );
                }

                if (state is ProjectError) {
                  return _buildErrorState(state.message);
                }

                return const Center(
                  child: Text('No projects available'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    final sortOptions = [
      'Newest',
      'Oldest',
      'Budget (High to Low)',
      'Budget (Low to High)',
      'Title A-Z',
    ];

    return DropdownButtonFormField<String>(
      value: _selectedSort,
      decoration: InputDecoration(
        labelText: 'Sort by',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: sortOptions.map((sort) {
        return DropdownMenuItem<String>(
          value: sort,
          child: Text(
            sort,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) {
          _onSortChanged(value);
        }
      },
    );
  }

  Widget _buildEmptyState() {
    if (_currentSearchQuery != null || _selectedFilter != 'All') {
      // No results for current filters
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No projects found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedFilter = 'All';
                  _currentSearchQuery = null;
                });
                _loadProjects();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    } else {
      // No projects at all
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first project to get started',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.router.push(CreateProjectRoute());
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading projects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProjects,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
