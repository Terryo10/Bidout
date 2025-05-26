import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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
    required this.status,
    required this.bidsCount,
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
        child: Row(
          children: [
            // Project Image or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultIcon();
                        },
                      ),
                    )
                  : _buildDefaultIcon(),
            ),
            const SizedBox(width: 16),
            // Project Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${budget.toString()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        bidsCount.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                      const Text(
                        'bids',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return const Center(
      child: Icon(
        Icons.work_outline,
        size: 24,
        color: AppColors.primary,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open for bids':
      case 'request_for_bids_received':
      case 'sourcing_of_vendors':
        return AppColors.info;
      case 'in progress':
      case 'project_in_progress':
      case 'project_being_scheduled':
        return AppColors.warning;
      case 'completed':
      case 'project_completed':
        return AppColors.success;
      case 'bids_ready_for_approval':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}