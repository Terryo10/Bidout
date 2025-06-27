import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';

class ProjectPreviewCard extends StatelessWidget {
  final String title;
  final String service;
  final int budget;
  final String status;
  final int bidsCount;
  final String? imageUrl;
  final VoidCallback onTap;

  const ProjectPreviewCard({
    super.key,
    required this.title,
    required this.service,
    required this.budget,
    required this.bidsCount,
    required this.status,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderLight),
        ),
        child: Row(
          children: [
            // Project Image or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultIcon(context);
                        },
                      ),
                    )
                  : _buildDefaultIcon(context),
            ),
            const SizedBox(width: 16),
            // Project Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _getStatusColor(context, status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(context, status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${budget.toString()}',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Bids Count and Arrow
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        bidsCount.toString(),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'bids',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: context.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Center(
      child: Icon(
        Icons.work_outline,
        size: 24,
        color: context.colors.primary,
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'open for bids':
      case 'request_for_bids_received':
      case 'sourcing_of_vendors':
        return context.info;
      case 'in progress':
      case 'project_in_progress':
      case 'project_being_scheduled':
        return context.warning;
      case 'completed':
      case 'project_completed':
        return context.success;
      case 'bids_ready_for_approval':
        return context.colors.primary;
      default:
        return context.textSecondary;
    }
  }
}
