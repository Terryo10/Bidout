// lib/ui/contractors/contractor_directory_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:bidout/ui/widgets/contractor_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_colors.dart';
import '../../models/contractor/contractor_model.dart';
import '../../repositories/contractor_repo/contractor_repo.dart';
import '../../routes/app_router.dart';
import '../widgets/contractor_card.dart';

@RoutePage()
class ContractorDirectoryPage extends StatefulWidget {
  const ContractorDirectoryPage({super.key});

  @override
  State<ContractorDirectoryPage> createState() =>
      _ContractorDirectoryPageState();
}

class _ContractorDirectoryPageState extends State<ContractorDirectoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ContractorModel> _contractors = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  String _selectedFilter = 'All';
  String _selectedSort = 'Rating';
  String? _currentSearchQuery;
  String? _selectedService;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _loadContractors();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadContractors() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final contractorRepository = context.read<ContractorRepository>();
      final contractors = await contractorRepository.getContractors(
        search: _currentSearchQuery,
        services: _selectedService != null ? [_selectedService!] : null,
        minRating: _minRating,
        isFeatured: _selectedFilter == 'Featured',
      );

      setState(() {
        _contractors = contractors.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _onScroll() {
    // Implement pagination if needed
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentSearchQuery = query.isNotEmpty ? query : null;
    });
    _debounceSearch();
  }

  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadContractors();
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadContractors();
  }

  void _onSortChanged(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _loadContractors();
  }

  void _onRefresh() {
    _loadContractors();
  }

  String? _mapSortToField(String sort) {
    switch (sort) {
      case 'Rating':
        return 'rating';
      case 'Name':
        return 'name';
      case 'Experience':
        return 'years_experience';
      default:
        return 'rating';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Contractors'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
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
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.grey50,
                  ),
                ),
                const SizedBox(height: 16),

                // Filter and Sort Row
                Row(
                  children: [
                    Expanded(
                      child: ContractorFilterWidget(
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

          // Contractors List
          Expanded(
            child: _buildContractorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    final sortOptions = [
      'Rating',
      'Name',
      'Experience',
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

  Widget _buildContractorsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return _buildErrorState(_errorMessage);
    }

    if (_contractors.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _onRefresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _contractors.length,
        itemBuilder: (context, index) {
          final contractor = _contractors[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ContractorCard(
              contractor: contractor,
              onTap: () {
                _navigateToContractorProfile(contractor);
              },
            ),
          );
        },
      ),
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
                setState(() {
                  _selectedFilter = 'All';
                  _currentSearchQuery = null;
                  _selectedService = null;
                  _minRating = null;
                });
                _loadContractors();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    } else {
      // No contractors at all
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
              'Check back later for available contractors',
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
            onPressed: _loadContractors,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        selectedService: _selectedService,
        minRating: _minRating,
        onServiceChanged: (service) {
          setState(() {
            _selectedService = service;
          });
        },
        onRatingChanged: (rating) {
          setState(() {
            _minRating = rating;
          });
        },
        onApply: () {
          Navigator.pop(context);
          _loadContractors();
        },
        onClear: () {
          setState(() {
            _selectedService = null;
            _minRating = null;
          });
          Navigator.pop(context);
          _loadContractors();
        },
      ),
    );
  }

  void _navigateToContractorProfile(ContractorModel contractor) {
    context.pushRoute(ContractorPreviewRoute(contractorId: contractor.id));
  }
}

class FilterBottomSheet extends StatefulWidget {
  final String? selectedService;
  final double? minRating;
  final Function(String?) onServiceChanged;
  final Function(double?) onRatingChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const FilterBottomSheet({
    super.key,
    this.selectedService,
    this.minRating,
    required this.onServiceChanged,
    required this.onRatingChanged,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _tempSelectedService;
  double? _tempMinRating;

  @override
  void initState() {
    super.initState();
    _tempSelectedService = widget.selectedService;
    _tempMinRating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Contractors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Service Filter
          const Text(
            'Service Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _tempSelectedService,
            decoration: InputDecoration(
              hintText: 'Select a service',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Services')),
              DropdownMenuItem(value: 'plumbing', child: Text('Plumbing')),
              DropdownMenuItem(value: 'electrical', child: Text('Electrical')),
              DropdownMenuItem(value: 'carpentry', child: Text('Carpentry')),
              DropdownMenuItem(value: 'painting', child: Text('Painting')),
            ],
            onChanged: (value) {
              setState(() {
                _tempSelectedService = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Rating Filter
          const Text(
            'Minimum Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<double>(
            value: _tempMinRating,
            decoration: InputDecoration(
              hintText: 'Any rating',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Any Rating')),
              DropdownMenuItem(value: 4.0, child: Text('4+ Stars')),
              DropdownMenuItem(value: 3.0, child: Text('3+ Stars')),
              DropdownMenuItem(value: 2.0, child: Text('2+ Stars')),
            ],
            onChanged: (value) {
              setState(() {
                _tempMinRating = value;
              });
            },
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onServiceChanged(null);
                    widget.onRatingChanged(null);
                    widget.onClear();
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onServiceChanged(_tempSelectedService);
                    widget.onRatingChanged(_tempMinRating);
                    widget.onApply();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
