import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            color: statusInfo.color,
            size: isCompact ? 12 : 14,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo.label,
            style: TextStyle(
              color: statusInfo.color,
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'request_for_bids_received':
        return _StatusInfo(
          label: 'Open for Bids',
          color: AppColors.success,
          icon: Icons.campaign,
        );
      case 'sourcing_of_vendors':
        return _StatusInfo(
          label: 'Sourcing Vendors',
          color: AppColors.info,
          icon: Icons.search,
        );
      case 'bids_ready_for_approval':
        return _StatusInfo(
          label: 'Under Review',
          color: AppColors.warning,
          icon: Icons.rate_review,
        );
      case 'project_being_scheduled':
        return _StatusInfo(
          label: 'Scheduling',
          color: AppColors.warning,
          icon: Icons.schedule,
        );
      case 'project_in_progress':
        return _StatusInfo(
          label: 'In Progress',
          color: AppColors.primary,
          icon: Icons.work,
        );
      case 'project_completed':
        return _StatusInfo(
          label: 'Completed',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      default:
        return _StatusInfo(
          label: 'Unknown',
          color: AppColors.textTertiary,
          icon: Icons.info,
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  _StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}
