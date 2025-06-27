import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: filters.map((filter) {
        return DropdownMenuItem<String>(
          value: filter,
          child: Text(
            filter,
            style: TextStyle(
              fontSize: 14,
              color: context.textPrimary,
            ),
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
