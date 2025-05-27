// lib/ui/contractor/find_contractors_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/contractor_bloc/contractor_bloc.dart';
import '../../constants/app_colors.dart';
import '../../models/contractor/contractor_model.dart';
import '../../models/services/service_model.dart';
import '../../repositories/contractor_repo/contractor_repository.dart';
import '../../repositories/projects_repo/projects_repository.dart';
import '../widgets/contractor_card.dart';
import '../widgets/contractor_filter_widget.dart';

class FindContractorsPage extends StatefulWidget {
  const FindContractorsPage({super.key});

  @override
  State<FindContractorsPage> createState() => _FindContractorsPageState();
}

class _FindContractorsPageState extends State<FindContractorsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ServiceModel> _services = [];
  bool _isLoadingServices = true;
  
  @override
  void initState() {
    super.initState();
    _loadServices();
    _scrollController.addListener(_onScroll);
    
    // Load initial contractors
    context.read<ContractorBloc>().add(const ContractorLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final projectRepository = context.read<ProjectRepository>();
      final services = await projectRepository.getServices();
      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<ContractorBloc>().state;
      if (currentState is ContractorLoaded && !currentState.hasReachedMax) {
        context.read<ContractorBloc>().add(const ContractorLoadMoreRequested());
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _searchController.text == query) {
        final currentState = context.read<ContractorBloc>().state;
        ContractorFilters filters = const ContractorFilters();
        
        if (currentState is ContractorLoaded) {
          filters = currentState.currentFilters;
        }
        
        context.read<ContractorBloc>().add(ContractorSearchRequested(
          query: query,
          services: filters.services,
          minRating: filters.minRating,
          location: filters.location,
          isFeatured: filters.isFeatured,
          hasSubscription: filters.hasSubscription,
        ));
      }
    });
  }

  void _onFilterChanged(ContractorFilters filters) {
    context.read<ContractorBloc>().add(ContractorFilterChanged(filters: filters));
  }

  void _onRefresh() {
    context.read<ContractorBloc>().add(const ContractorRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Contractors'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search contractors...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.grey50,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Widget
                if (!_isLoadingServices)
                  BlocBuilder<ContractorBloc, ContractorState>(
                    builder: (context, state) {
                      ContractorFilters currentFilters = const ContractorFilters();
                      if (state is ContractorLoaded) {
                        currentFilters = state.currentFilters;
                      }
                      
                      return ContractorFilterWidget(
                        services: _services,
                        currentFilters: currentFilters,
                        onFilterChanged: _onFilterChanged,
                      );
                    },
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppColors.borderLight),
          
          // Contractors List
          Expanded(
            child: BlocConsumer<ContractorBloc, ContractorState>(
              listener: (context, state) {
                if (state is ContractorError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ContractorLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is ContractorLoaded) {
                  final contractors = state.contractors.data;
                  
                  if (contractors.isEmpty) {
                    return _buildEmptyState(state.currentFilters);
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      _onRefresh();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: contractors.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= contractors.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final contractor = contractors[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ContractorCard(
                            contractor: contractor,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ContractorDetailPage(
                                    contractorId: contractor.id,
                                  ),
                                ),
                              );
                            },
                            onContact: () => _contactContractor(contractor),
                            onViewPortfolio: contractor.featuredPortfolios.isNotEmpty
                                ? () => _viewContractorPortfolio(contractor)
                                : null,
                          ),
                        );
                      },
                    ),
                  );
                }
                
                if (state is ContractorError) {
                  return _buildErrorState(state.message);
                }
                
                return const Center(
                  child: Text('No contractors available'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ContractorFilters filters) {
    if (filters.hasActiveFilters) {
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
              'No contractors found',
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
                context.read<ContractorBloc>().add(
                  const ContractorFilterChanged(filters: ContractorFilters()),
                );
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No contractors available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new contractors',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
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
            'Error loading contractors',
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
            onPressed: _onRefresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _contactContractor(ContractorModel contractor) {
    // Show contact options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact ${contractor.displayName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (contractor.email.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.email, color: AppColors.primary),
                title: const Text('Send Email'),
                subtitle: Text(contractor.email),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open email app
                },
              ),
            if (contractor.phone != null)
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.success),
                title: const Text('Call'),
                subtitle: Text(contractor.phone!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open phone app
                },
              ),
            if (contractor.website != null)
              ListTile(
                leading: const Icon(Icons.web, color: AppColors.info),
                title: const Text('Visit Website'),
                subtitle: Text(contractor.website!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open web browser
                },
              ),
          ],
        ),
      ),
    );
  }

  void _viewContractorPortfolio(ContractorModel contractor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContractorPortfolioPage(
          contractorId: contractor.id,
          contractorName: contractor.displayName,
        ),
      ),
    );
  }
}

// lib/ui/contractor/contractor_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/contractor_bloc/contractor_bloc.dart';
import '../../constants/app_colors.dart';
import '../../models/contractor/contractor_model.dart';
import '../widgets/contractor_info_section.dart';
import '../widgets/contractor_portfolio_preview.dart';
import '../widgets/contractor_services_section.dart';
import '../widgets/contractor_stats_section.dart';

class ContractorDetailPage extends StatefulWidget {
  final int contractorId;

  const ContractorDetailPage({
    super.key,
    required this.contractorId,
  });

  @override
  State<ContractorDetailPage> createState() => _ContractorDetailPageState();
}

class _ContractorDetailPageState extends State<ContractorDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ContractorBloc>().add(
      ContractorSingleLoadRequested(contractorId: widget.contractorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ContractorBloc, ContractorState>(
        listener: (context, state) {
          if (state is ContractorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ContractorSingleLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Contractor Details'),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is ContractorSingleLoaded) {
            return _buildContractorDetails(state.contractor);
          }

          if (state is ContractorError) {
            return _buildErrorView();
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Contractor Details'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContractorDetails(ContractorModel contractor) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                contractor.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: contractor.avatar != null
                            ? NetworkImage(contractor.avatar!)
                            : null,
                        backgroundColor: AppColors.white.withOpacity(0.2),
                        child: contractor.avatar == null
                            ? Text(
                                contractor.name.isNotEmpty
                                    ? contractor.name[0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      if (contractor.businessName != null)
                        Text(
                          contractor.businessName!,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareContractor(contractor),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'contact':
                      _contactContractor(contractor);
                      break;
                    case 'report':
                      _reportContractor(contractor);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'contact',
                    child: Row(
                      children: [
                        Icon(Icons.contact_mail, size: 20),
                        SizedBox(width: 8),
                        Text('Contact'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report, size: 20),
                        SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Section
                ContractorStatsSection(contractor: contractor),
                const SizedBox(height: 24),

                // Services Section
                ContractorServicesSection(contractor: contractor),
                const SizedBox(height: 24),

                // Info Section
                ContractorInfoSection(contractor: contractor),
                const SizedBox(height: 24),

                // Portfolio Preview
                if (contractor.featuredPortfolios.isNotEmpty)
                  ContractorPortfolioPreview(contractor: contractor),

                const SizedBox(height: 24),

                // Contact Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _contactContractor(contractor),
                    icon: const Icon(Icons.contact_mail),
                    label: const Text('Contact Contractor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Space for FAB
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: 16),
            Text(
              'Contractor not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The requested contractor could not be loaded',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareContractor(ContractorModel contractor) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality not implemented yet')),
    );
  }

  void _contactContractor(ContractorModel contractor) {
    // Show contact options modal
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact ${contractor.displayName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (contractor.email.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.email, color: AppColors.primary),
                title: const Text('Send Email'),
                subtitle: Text(contractor.email),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open email app
                },
              ),
            if (contractor.phone != null)
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.success),
                title: const Text('Call'),
                subtitle: Text(contractor.phone!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open phone app
                },
              ),
            if (contractor.website != null)
              ListTile(
                leading: const Icon(Icons.web, color: AppColors.info),
                title: const Text('Visit Website'),
                subtitle: Text(contractor.website!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open web browser
                },
              ),
          ],
        ),
      ),
    );
  }

  void _reportContractor(ContractorModel contractor) {
    // TODO: Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report functionality not implemented yet')),
    );
  }
}