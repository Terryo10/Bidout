import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../constants/app_urls.dart';
import '../../models/contractor/contractor_model.dart';
import '../../models/contractor/portfolio_model.dart';

class ContractorPortfolioPreview extends StatelessWidget {
  final ContractorModel contractor;

  const ContractorPortfolioPreview({
    super.key,
    required this.contractor,
  });

  @override
  Widget build(BuildContext context) {
    if (contractor.featuredPortfolios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Portfolio',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full portfolio
              },
              child: Text(
                'View All',
                style: TextStyle(color: context.colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: contractor.featuredPortfolios.length,
            itemBuilder: (context, index) {
              final portfolio = contractor.featuredPortfolios[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right:
                      index < contractor.featuredPortfolios.length - 1 ? 16 : 0,
                ),
                child: _PortfolioCard(portfolio: portfolio),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final PortfolioModel portfolio;

  const _PortfolioCard({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Image
          if (portfolio.primaryImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                AppUrls.getStorageUrl(portfolio.primaryImage!.imageUrl),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: context.colors.surfaceContainer,
                    child: Icon(
                      Icons.image_not_supported,
                      color: context.textSecondary,
                    ),
                  );
                },
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolio.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (portfolio.projectType != null) ...[
                  const SizedBox(height: 4),
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
                      portfolio.projectType!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ],
                if (portfolio.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    portfolio.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
