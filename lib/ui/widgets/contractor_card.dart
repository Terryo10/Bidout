// lib/ui/widgets/contractor_card.dart
import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../constants/app_urls.dart';
import '../../models/contractor/contractor_model.dart';

class ContractorCard extends StatelessWidget {
  final ContractorModel contractor;
  final VoidCallback onTap;

  const ContractorCard({
    super.key,
    required this.contractor,
    required this.onTap,
  });

  String? _getAvatarUrl(String? path) {
    if (path == null) return null;
    return '${AppUrls.baseUrl}/storage/$path';
  }

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
        child: Container(
          decoration: contractor.isFeatured
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.warning,
                    width: 2,
                  ),
                )
              : null,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: contractor.avatar != null
                        ? NetworkImage(_getAvatarUrl(contractor.avatar)!)
                        : null,
                    backgroundColor: context.colors.primary.withOpacity(0.1),
                    child: contractor.avatar == null
                        ? Text(
                            contractor.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contractor.displayName,
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: context.textPrimary,
                                ),
                              ),
                            ),
                            if (contractor.isFeatured)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.star,
                                  color: context.warning,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        if (contractor.businessName != null)
                          Text(
                            contractor.businessName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: contractor.rating > 0
                                  ? context.warning
                                  : context.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              contractor.ratingDisplay,
                              style: TextStyle(
                                fontSize: 14,
                                color: contractor.rating > 0
                                    ? context.warning
                                    : context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Services
              if (contractor.services.isNotEmpty) ...[
                Text(
                  'Services',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: contractor.services.map((service) {
                    return Chip(
                      label: Text(service.service?.name ?? 'Unknown Service'),
                      backgroundColor: context.colors.primary.withOpacity(0.1),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: context.colors.primary,
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
                            Text(
                              'Experience',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                            Text(
                              '${contractor.yearsExperience} years',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
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
                            Text(
                              'Hourly Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                            Text(
                              '\$${contractor.hourlyRate!.toStringAsFixed(2)}/hr',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              // Service Areas
              if (contractor.serviceAreas?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        contractor.serviceAreas!.join(', '),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
