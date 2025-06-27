// lib/ui/widgets/contractor_card.dart
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/contractor/contractor_model.dart';

class ContractorCard extends StatelessWidget {
  final ContractorModel contractor;
  final VoidCallback onTap;

  const ContractorCard({
    super.key,
    required this.contractor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: contractor.avatar != null
                        ? NetworkImage(contractor.avatar!)
                        : null,
                    child: contractor.avatar == null
                        ? Text(
                            contractor.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contractor.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (contractor.businessName != null)
                          Text(
                            contractor.businessName!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          contractor.ratingDisplay,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Services
              if (contractor.services.isNotEmpty) ...[
                const Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: contractor.services.map((service) {
                    return Chip(
                      label: Text(service.service?.name ?? 'Unknown Service'),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    );
                  }).toList(),
                ),
              ],
              // Experience and Rate
              if (contractor.yearsExperience != null ||
                  contractor.hourlyRate != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (contractor.yearsExperience != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Experience',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${contractor.yearsExperience} years',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (contractor.hourlyRate != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '\$${contractor.hourlyRate!.toStringAsFixed(2)}/hr',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
