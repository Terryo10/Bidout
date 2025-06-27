import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/contractor/contractor_model.dart';

class ContractorStatsSection extends StatelessWidget {
  final ContractorModel contractor;

  const ContractorStatsSection({
    super.key,
    required this.contractor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderLight),
        boxShadow: [
          BoxShadow(
            color: context.colors.surface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: context.textTheme.titleLarge?.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context,
                'Rating',
                contractor.ratingDisplay,
                Icons.star,
                context.warning,
              ),
              _buildStatItem(
                context,
                'Experience',
                '${contractor.yearsExperience ?? 0} years',
                Icons.work,
                context.info,
              ),
              _buildStatItem(
                context,
                'Rate',
                contractor.hourlyRate != null
                    ? '\$${contractor.hourlyRate!.toStringAsFixed(2)}/hr'
                    : 'Not specified',
                Icons.monetization_on,
                context.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}
