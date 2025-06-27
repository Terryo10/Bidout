// lib/ui/widgets/contractor_review_card.dart
import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/contractor/contractor_review_model.dart';

class ContractorReviewCard extends StatelessWidget {
  final ContractorReviewModel review;

  const ContractorReviewCard({
    super.key,
    required this.review,
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
          // Reviewer Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Name and Project
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.clientName,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  if (review.projectTitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      review.projectTitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              // Date
              Text(
                review.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating Stars
          Row(
            children: [
              Text(
                review.starsDisplay,
                style: TextStyle(
                  color: context.warning,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${review.rating}/5',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Review Text
          Text(
            review.reviewText,
            style: TextStyle(
              fontSize: 14,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
