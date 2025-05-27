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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      image: contractor.avatar != null
                          ? DecorationImage(
                              image: NetworkImage(contractor.avatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: contractor.avatar == null
                        ? const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Name and Business Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contractor.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (contractor.hasGoldenBadge)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.warning.withOpacity(0.3),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.warning,
                                      size: 12,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (contractor.businessName != null &&
                            contractor.businessName != contractor.name)
                          Text(
                            contractor.businessName!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),

                        // Rating
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < contractor.rating.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColors.warning,
                                size: 16,
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              contractor.formattedRating,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bio/Description
              if (contractor.bio != null)
                Text(
                  contractor.bio!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Services
              if (contractor.services.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: contractor.services.take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service.serviceName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),

              // Footer Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Experience and Rate
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contractor.experienceText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on_outlined,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contractor.rateText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Location and Availability
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (contractor.serviceAreas.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              contractor.serviceAreas.first,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: contractor.availableForHire
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          contractor.availableForHire ? 'Available' : 'Busy',
                          style: TextStyle(
                            fontSize: 10,
                            color: contractor.availableForHire
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
