// lib/ui/projects/project_view_page.dart (Updated)
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/projects_bloc/project_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/projects/project_model.dart';
import '../../routes/app_router.dart';
import '../widgets/project_image_gallery.dart';
import '../widgets/project_status_chip.dart';

@RoutePage()
class ProjectViewPage extends StatefulWidget {
  final int projectId;
  final ProjectModel? project;

  const ProjectViewPage({
    super.key,
    required this.projectId,
    this.project,
  });

  @override
  State<ProjectViewPage> createState() => _ProjectViewPageState();
}

class _ProjectViewPageState extends State<ProjectViewPage> {
  @override
  void initState() {
    super.initState();
    if (widget.project == null) {
      _loadProject();
    }
  }

  void _loadProject() {
    context.read<ProjectBloc>().add(
          ProjectSingleLoadRequested(projectId: widget.projectId),
        );
  }

  @override
  Widget build(BuildContext context) {
    // If we have the project directly, use it
    if (widget.project != null) {
      return _buildProjectView(widget.project!);
    }

    return Scaffold(
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.error,
              ),
            );
          } else if (state is ProjectDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Project deleted successfully'),
                backgroundColor: context.success,
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
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
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
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
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
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
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
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: context.textSecondary),
                    const SizedBox(width: 8),
                    const Text('Edit Project'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: context.textSecondary),
                    const SizedBox(width: 8),
                    const Text('Share Project'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: context.error),
                    const SizedBox(width: 8),
                    const Text('Delete Project'),
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
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
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
                                  color:
                                      context.colors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  project.service!.name,
                                  style: TextStyle(
                                    color: context.colors.primary,
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
                          context.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          'Frequency',
                          project.frequency,
                          Icons.schedule,
                          context.warning,
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
                            context.info,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            'End Date',
                            '${project.endDate!.day}/${project.endDate!.month}/${project.endDate!.year}',
                            Icons.stop,
                            context.error,
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
                      project.provinceId != null ||
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

                  // Action Buttons
                  _buildActionButtons(project),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Project not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The requested project could not be loaded',
              style: TextStyle(
                color: context.textSecondary,
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderLight),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withOpacity(0.05),
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
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderLight),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: context.textPrimary,
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
    if (project.provinceId != null)
      locationParts.add(project.provinceId!.toString());
    if (project.zipCode != null) locationParts.add(project.zipCode!);

    final locationString = locationParts.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderLight),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: context.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  locationString.isNotEmpty
                      ? locationString
                      : 'Location not specified',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.textPrimary,
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderLight),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Important Factor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderLight),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  color: context.colors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Created: ${_formatDate(project.createdAt)}',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.update, color: context.warning, size: 20),
              const SizedBox(width: 12),
              Text(
                'Last updated: ${_formatDate(project.updatedAt)}',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProjectModel project) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUser =
            authState is AuthAuthenticated ? authState.user : null;
        final isContractor = currentUser?.hasContractorRole ?? false;
        final isClient = currentUser?.hasClientRole ?? false;

        return BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, projectState) {
            // Check if user has already bid on this project
            bool userHasBid = false;
            if (projectState is ProjectSingleLoaded &&
                projectState.userHasBid != null) {
              userHasBid = projectState.userHasBid!;
            }

            return Column(
              children: [
                // Submit Bid button for contractors (only if they haven't bid yet)
                if (isContractor && project.isInBidPhase() && !userHasBid)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _submitBid(project),
                          icon: const Icon(Icons.send),
                          label: const Text('Submit Bid'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Show "Bid Submitted" message if contractor has already bid
                if (isContractor && project.isInBidPhase() && userHasBid)
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: context.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.info),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: context.info),
                            const SizedBox(width: 8),
                            Text(
                              'Bid Submitted',
                              style: TextStyle(
                                color: context.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // View Bids button for clients
                if (isClient && project.isInBidPhase())
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _viewBids(project),
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Bids'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            foregroundColor: context.colors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Edit and Share buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editProject(project),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.primary,
                          side: BorderSide(color: context.colors.primary),
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
                          foregroundColor: context.colors.secondary,
                          side: BorderSide(color: context.colors.secondary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getKeyFactorColor(String keyFactor) {
    switch (keyFactor.toLowerCase()) {
      case 'quality':
        return context.success;
      case 'timeline':
        return context.warning;
      case 'cost':
        return context.info;
      default:
        return context.textSecondary;
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
            style: TextButton.styleFrom(foregroundColor: context.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareProject(ProjectModel project) {
    final url = 'http://127.0.0.1:8000/projects/${project.id}';
    Share.share(
      url,
      subject: 'Check out this project: ${project.title}',
    );
  }

  void _submitBid(ProjectModel project) {
    context.router.push(CreateBidRoute(project: project));
  }

  void _viewBids(ProjectModel project) {
    context.router.push(ProjectBidsRoute(project: project));
  }
}
