import 'package:flutter/material.dart';
import '../../constants/app_theme_extension.dart';

class ProjectStatusChip extends StatelessWidget {
  final String status;

  const ProjectStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusInfo.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            color: statusInfo.color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo.label,
            style: TextStyle(
              color: statusInfo.color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(BuildContext context, String status) {
    switch (status) {
      case 'request_for_bids_received':
        return _StatusInfo(
          label: 'Open for Bids',
          color: context.info,
          icon: Icons.assignment_turned_in,
        );
      case 'sourcing_of_vendors':
        return _StatusInfo(
          label: 'Sourcing Vendors',
          color: context.warning,
          icon: Icons.search,
        );
      case 'bids_ready_for_approval':
        return _StatusInfo(
          label: 'Reviewing Bids',
          color: context.colors.primary,
          icon: Icons.rate_review,
        );
      case 'project_being_scheduled':
        return _StatusInfo(
          label: 'Scheduling',
          color: context.warning,
          icon: Icons.schedule,
        );
      case 'project_in_progress':
        return _StatusInfo(
          label: 'In Progress',
          color: context.warning,
          icon: Icons.work,
        );
      case 'project_completed':
        return _StatusInfo(
          label: 'Completed',
          color: context.success,
          icon: Icons.check_circle,
        );
      default:
        return _StatusInfo(
          label: status,
          color: context.textSecondary,
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
