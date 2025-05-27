import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ContractorFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const ContractorFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      'All',
      'Featured',
      'Available',
      'Top Rated',
    ];

    return DropdownButtonFormField<String>(
      value: selectedFilter,
      decoration: InputDecoration(
        labelText: 'Filter contractors',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: filters.map((filter) {
        return DropdownMenuItem<String>(
          value: filter,
          child: Text(
            filter,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) {
          onFilterChanged(value);
        }
      },
    );
  }
}
