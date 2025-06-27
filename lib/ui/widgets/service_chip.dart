import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';

class ServiceChip extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const ServiceChip({
    super.key,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary
              ? context.colors.primary.withOpacity(0.1)
              : context.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? context.colors.primary.withOpacity(0.3)
                : context.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isPrimary ? context.colors.primary : context.textSecondary,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
