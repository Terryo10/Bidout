import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/projects/project_model.dart';

class ContractorProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ContractorProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (project.service?.name != null)
                          Text(
                            project.service!.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(context, project.status),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Budget and details row
              Row(
                children: [
                  // Budget
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: context.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${project.budget.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: context.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Frequency
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: context.info,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project.frequency,
                          style: TextStyle(
                            color: context.info,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Posted date
                  Text(
                    _formatDate(project.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textTertiary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Location if available
              if (project.city != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: context.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _buildLocationText(project),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Key factor
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: context.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Key Factor: ${_formatKeyFactor(project.keyFactor)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'request_for_bids_received':
        color = context.success;
        label = 'Open for Bids';
        icon = Icons.campaign;
        break;
      case 'sourcing_of_vendors':
        color = context.info;
        label = 'Sourcing';
        icon = Icons.search;
        break;
      case 'bids_ready_for_approval':
        color = context.warning;
        label = 'Under Review';
        icon = Icons.rate_review;
        break;
      default:
        color = context.textTertiary;
        label = 'Unknown';
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _buildLocationText(ProjectModel project) {
    final parts = <String>[];
    if (project.city != null) parts.add(project.city!);
    if (project.zipCode != null) parts.add(project.zipCode!);
    return parts.join(', ');
  }

  String _formatKeyFactor(String keyFactor) {
    return keyFactor
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
