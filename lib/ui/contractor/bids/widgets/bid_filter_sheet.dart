import 'package:flutter/material.dart';

import '../../../../constants/app_theme_extension.dart';
import '../../../widgets/custom_text_field.dart';

class BidFilterSheet extends StatefulWidget {
  final String? currentStatus;
  final String? currentSearch;
  final Function(String?, String?) onFiltersApplied;

  const BidFilterSheet({
    super.key,
    this.currentStatus,
    this.currentSearch,
    required this.onFiltersApplied,
  });

  @override
  State<BidFilterSheet> createState() => _BidFilterSheetState();
}

class _BidFilterSheetState extends State<BidFilterSheet> {
  late TextEditingController _searchController;
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Accepted',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.currentSearch);
    _selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: context.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Filter Bids',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear All',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search
                Text(
                  'Search',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _searchController,
                  label: 'Search',
                  hint: 'Search by project title...',
                  prefixIcon: Icons.search,
                ),

                const SizedBox(height: 24),

                // Status filter
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _statusOptions.map((status) {
                    final isSelected =
                        (_selectedStatus == null && status == 'All') ||
                            (_selectedStatus?.toLowerCase() ==
                                status.toLowerCase());

                    return FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (status == 'All') {
                            _selectedStatus = null;
                          } else {
                            _selectedStatus =
                                selected ? status.toLowerCase() : null;
                          }
                        });
                      },
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : context.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
    });
  }

  void _applyFilters() {
    final search = _searchController.text.trim().isEmpty
        ? null
        : _searchController.text.trim();

    widget.onFiltersApplied(_selectedStatus, search);
    Navigator.pop(context);
  }
}
