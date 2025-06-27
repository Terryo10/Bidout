// lib/ui/find_contractors/find_contractors.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/contractor_bloc/contractor_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/contractor/contractor_model.dart';
import '../../models/services/service_model.dart';
import '../../models/pagination/pagination_model.dart';
import '../../repositories/projects_repo/projects_repository.dart';
import '../../routes/app_router.dart';
import '../widgets/contractor_card.dart';

@RoutePage()
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
  String? _selectedService;
  double _minRating = 0.0;
  String? _selectedLocation;
  bool _showFeaturedOnly = false;

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

  void _onServiceSelected(ServiceModel service, bool selected) {
    setState(() {
      if (selected) {
        _selectedService = service.name;
      } else {
        _selectedService = null;
      }
    });

    _applyFilters();
  }

  void _applyFilters() {
    context.read<ContractorBloc>().add(
          ContractorSearchRequested(
            query: _searchController.text,
            services: _selectedService != null ? [_selectedService!] : null,
            minRating: _minRating > 0 ? _minRating : null,
            location: _selectedLocation,
            isFeatured: _showFeaturedOnly,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Contractors'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: context.colors.surface,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search contractors...',
                prefixIcon: Icon(Icons.search, color: context.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                fillColor: context.colors.surfaceContainer,
                filled: true,
              ),
            ),
          ),

          // Services Filter
          if (!_isLoadingServices && _services.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _services.map((service) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(service.name),
                      selected: service.name == _selectedService,
                      onSelected: (selected) =>
                          _onServiceSelected(service, selected),
                      selectedColor: context.colors.primary.withOpacity(0.2),
                      checkmarkColor: context.colors.primary,
                      backgroundColor: context.colors.surface,
                      side: BorderSide(color: context.borderLight),
                      labelStyle: TextStyle(
                        color: service.name == _selectedService
                            ? context.colors.primary
                            : context.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Active Filters Display
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.filter_list,
                      size: 16, color: context.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    _getActiveFiltersText(),
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: context.colors.primary),
                    ),
                  ),
                ],
              ),
            ),

          // Contractors List
          Expanded(
            child: BlocBuilder<ContractorBloc, ContractorState>(
              builder: (context, state) {
                if (state is ContractorInitial) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ContractorError) {
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
                          state.message,
                          style: TextStyle(
                            color: context.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ContractorBloc>().add(
                                  const ContractorLoadRequested(),
                                );
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

                if (state is ContractorLoaded) {
                  if (state.contractors.data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: context.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No contractors found',
                            style: context.textTheme.titleLarge?.copyWith(
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ContractorBloc>().add(
                            const ContractorRefreshRequested(),
                          );
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.contractors.data.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.contractors.data.length) {
                          return state.hasReachedMax
                              ? const SizedBox()
                              : const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                        }

                        final contractor = state.contractors.data[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ContractorCard(
                            contractor: contractor,
                            onTap: () =>
                                _navigateToContractorDetails(contractor),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToContractorDetails(ContractorModel contractor) {
    context.pushRoute(ContractorPreviewRoute(contractorId: contractor.id));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Contractors',
          style: context.textTheme.titleLarge?.copyWith(
            color: context.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Minimum Rating Slider
            Text(
              'Minimum Rating',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.textPrimary,
              ),
            ),
            Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 10,
              label: _minRating.toString(),
              activeColor: context.colors.primary,
              inactiveColor: context.colors.primary.withOpacity(0.2),
              onChanged: (value) {
                setState(() {
                  _minRating = value;
                });
              },
            ),

            // Featured Only Switch
            SwitchListTile(
              title: Text(
                'Featured Contractors Only',
                style: TextStyle(color: context.textPrimary),
              ),
              value: _showFeaturedOnly,
              activeColor: context.colors.primary,
              onChanged: (value) {
                setState(() {
                  _showFeaturedOnly = value;
                });
              },
            ),

            // Location Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: TextStyle(color: context.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.primary),
                ),
                filled: true,
                fillColor: context.colors.surfaceContainer,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Any Location')),
                DropdownMenuItem(value: 'New York', child: Text('New York')),
                DropdownMenuItem(
                    value: 'Los Angeles', child: Text('Los Angeles')),
                // Add more locations as needed
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedService != null ||
      _minRating > 0 ||
      _selectedLocation != null ||
      _showFeaturedOnly;

  String _getActiveFiltersText() {
    List<String> filters = [];
    if (_selectedService != null) {
      filters.add('Service: $_selectedService');
    }
    if (_minRating > 0) {
      filters.add('Rating: ≥${_minRating.toStringAsFixed(1)}');
    }
    if (_selectedLocation != null) {
      filters.add('Location: $_selectedLocation');
    }
    if (_showFeaturedOnly) {
      filters.add('Featured Only');
    }
    return filters.join(' • ');
  }

  void _clearFilters() {
    setState(() {
      _selectedService = null;
      _minRating = 0;
      _selectedLocation = null;
      _showFeaturedOnly = false;
    });
    _applyFilters();
  }
}
