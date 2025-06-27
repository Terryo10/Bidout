import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/contractor/contractor_model.dart';

class ContractorServicesSection extends StatelessWidget {
  final ContractorModel contractor;

  const ContractorServicesSection({
    super.key,
    required this.contractor,
  });

  @override
  Widget build(BuildContext context) {
    if (contractor.services.isEmpty) {
      return const SizedBox.shrink();
    }

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
            'Services Offered',
            style: context.textTheme.titleLarge?.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...contractor.services.map((service) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.service?.name ?? 'Unknown Service',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      if (service.isPrimaryService)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Primary',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildServiceDetail(
                        context,
                        'Experience',
                        '${service.experienceYears} years',
                        Icons.work,
                      ),
                      const SizedBox(width: 16),
                      _buildServiceDetail(
                        context,
                        'Rate',
                        '\$${service.hourlyRate.toStringAsFixed(2)}/hr',
                        Icons.monetization_on,
                      ),
                    ],
                  ),
                  if (service.specializationNotes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      service.specializationNotes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceDetail(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: context.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 14,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}
