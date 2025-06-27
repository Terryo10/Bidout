// lib/ui/widgets/portfolio_item_card.dart
import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/contractor/portfolio_model.dart';

class PortfolioItemCard extends StatelessWidget {
  final PortfolioModel portfolioItem;
  final VoidCallback onTap;

  const PortfolioItemCard({
    super.key,
    required this.portfolioItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: portfolioItem.primaryImage != null
                    ? Image.network(
                        portfolioItem.primaryImage!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(context);
                        },
                      )
                    : _buildPlaceholderImage(context),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Featured Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          portfolioItem.title,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (portfolioItem.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.star,
                            color: context.warning,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Project Type
                  if (portfolioItem.projectType != null)
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
                        portfolioItem.projectType!,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Description
                  if (portfolioItem.description != null)
                    Text(
                      portfolioItem.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),

                  // Footer Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Value
                      if (portfolioItem.projectValue != null)
                        Text(
                          portfolioItem.formattedValue,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.success,
                          ),
                        ),

                      // Completion Date
                      Text(
                        portfolioItem.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: context.colors.surfaceContainer,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: context.textSecondary,
        ),
      ),
    );
  }
}
