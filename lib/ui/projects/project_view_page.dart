// lib/ui/projects/project_view_page.dart (Updated)
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/projects_bloc/project_bloc.dart';
import '../../constants/app_colors.dart';
import '../../models/projects/project_model.dart';
import '../../routes/app_router.dart';
import '../widgets/project_image_gallery.dart';
import '../widgets/project_status_chip.dart';

@RoutePage()
class ProjectViewPage extends StatefulWidget {
  final int projectId;

  const ProjectViewPage({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectViewPage> createState() => _ProjectViewPageState();
}

class _ProjectViewPageState extends State<ProjectViewPage> {
  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  void _loadProject() {
    context.read<ProjectBloc>().add(
          ProjectSingleLoadRequested(projectId: widget.projectId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is ProjectDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Project deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            context.router.pop();
          }
        },
        builder: (context, state) {
          if (state is ProjectSingleLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Project Details'),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is ProjectSingleLoaded) {
            return _buildProjectView(state.project);
          }

          if (state is ProjectError) {
            return _buildErrorView();
          }

          // If no specific state, try to load the project
          return Scaffold(
            appBar: AppBar(
              title: const Text('Project Details'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectView(ProjectModel project) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editProject(project);
                  break;
                case 'delete':
                  _deleteProject(project);
                  break;
                case 'share':
                  _shareProject(project);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Edit Project'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Share Project'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Project'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Images
            if (project.images.isNotEmpty)
              ProjectImageGallery(images: project.images),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (project.service != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  project.service!.name,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ProjectStatusChip(status: project.status),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Budget and Timeline
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Budget',
                          '\$${project.budget.toStringAsFixed(0)}',
                          Icons.monetization_on,
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          'Frequency',
                          project.frequency,
                          Icons.schedule,
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Project Dates
                  if (project.startDate != null && project.endDate != null)
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Start Date',
                            '${project.startDate!.day}/${project.startDate!.month}/${project.startDate!.year}',
                            Icons.play_arrow,
                            AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            'End Date',
                            '${project.endDate!.day}/${project.endDate!.month}/${project.endDate!.year}',
                            Icons.stop,
                            AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Description Section
                  _buildSection(
                    'Description',
                    project.description,
                  ),
                  const SizedBox(height: 24),

                  // Additional Requirements
                  if (project.additionalRequirements != null &&
                      project.additionalRequirements!.isNotEmpty)
                    Column(
                      children: [
                        _buildSection(
                          'Additional Requirements',
                          project.additionalRequirements!,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Location Information
                  if (project.street != null ||
                      project.city != null ||
                      project.state != null ||
                      project.zipCode != null)
                    Column(
                      children: [
                        _buildLocationSection(project),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Key Factor
                  _buildKeyFactorSection(project),
                  const SizedBox(height: 24),

                  // Project Timeline
                  _buildTimelineCard(project),
                  const SizedBox(height: 24),

                  // Client Information
                  //if (project.client != null) _buildClientSection(project),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(project),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: project.isInBidPhase()
          ? FloatingActionButton.extended(
              onPressed: () => _submitBid(project),
              icon: const Icon(Icons.assignment_turned_in),
              label: const Text('Submit Bid'),
              backgroundColor: AppColors.secondary,
            )
          : null,
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Project not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The requested project could not be loaded',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.router.pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(ProjectModel project) {
    final locationParts = <String>[];

    if (project.street != null) locationParts.add(project.street!);
    if (project.city != null) locationParts.add(project.city!);
    if (project.state != null) locationParts.add(project.state!);
    if (project.zipCode != null) locationParts.add(project.zipCode!);

    final locationString = locationParts.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  locationString.isNotEmpty
                      ? locationString
                      : 'Location not specified',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFactorSection(ProjectModel project) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most Important Factor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getKeyFactorColor(project.keyFactor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getKeyFactorIcon(project.keyFactor),
                  color: _getKeyFactorColor(project.keyFactor),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  project.keyFactor.toUpperCase(),
                  style: TextStyle(
                    color: _getKeyFactorColor(project.keyFactor),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(ProjectModel project) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Created: ${_formatDate(project.createdAt)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.update, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              Text(
                'Last updated: ${_formatDate(project.updatedAt)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection(ProjectModel project) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  // project.client!.name[0].toUpperCase(),
                  'Client Name',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // project.client!.name,
                      'Client Name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      // project.client!.email,
                      'client@example.com',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProjectModel project) {
    return Column(
      children: [
        if (project.isInBidPhase())
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _viewBids(project),
              icon: const Icon(Icons.visibility),
              label: const Text('View Bids'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editProject(project),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareProject(project),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getKeyFactorColor(String keyFactor) {
    switch (keyFactor.toLowerCase()) {
      case 'quality':
        return AppColors.success;
      case 'timeline':
        return AppColors.warning;
      case 'cost':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getKeyFactorIcon(String keyFactor) {
    switch (keyFactor.toLowerCase()) {
      case 'quality':
        return Icons.star;
      case 'timeline':
        return Icons.schedule;
      case 'cost':
        return Icons.monetization_on;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editProject(ProjectModel project) {
    // Navigate to edit project page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit project functionality not implemented yet')),
    );
  }

  void _deleteProject(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
            'Are you sure you want to delete this project? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProjectBloc>().add(
                    ProjectDeleteRequested(projectId: project.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareProject(ProjectModel project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Share project functionality not implemented yet')),
    );
  }

  void _submitBid(ProjectModel project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Submit bid functionality not implemented yet')),
    );
  }

  void _viewBids(ProjectModel project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('View bids functionality not implemented yet')),
    );
  }
}
