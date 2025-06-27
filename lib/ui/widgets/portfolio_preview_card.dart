import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../constants/app_urls.dart';
import '../../models/contractor/portfolio_model.dart';

class PortfolioPreviewCard extends StatelessWidget {
  final PortfolioModel portfolio;
  final VoidCallback? onTap;

  const PortfolioPreviewCard({
    super.key,
    required this.portfolio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.textSecondary.withOpacity(0.2),
            width: 1,
          ),
          color: context.colors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Image
            if (portfolio.images.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  AppUrls.getStorageUrl(portfolio.primaryImage?.imageUrl),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: context.textSecondary.withOpacity(0.1),
                    child: Icon(
                      Icons.image_not_supported,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.textSecondary.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Icon(
                  Icons.image,
                  color: context.textSecondary,
                ),
              ),

            // Portfolio Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    portfolio.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (portfolio.description != null)
                    Text(
                      portfolio.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
