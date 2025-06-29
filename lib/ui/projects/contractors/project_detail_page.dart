import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contractor_projects_bloc/contractor_projects_bloc.dart';
import '../../../constants/app_theme_extension.dart';
import '../../../constants/app_urls.dart';
import '../../../models/projects/project_model.dart';
import '../../../routes/app_router.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/project_image_carousel.dart';
import '../../widgets/status_badge.dart';

class ProjectDetailPage extends StatefulWidget {
  final int projectId;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ContractorProjectsBloc>().add(
          ContractorProjectsSingleLoadRequested(projectId: widget.projectId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Project Details',
        showBackButton: true,
      ),
      body: BlocBuilder<ContractorProjectsBloc, ContractorProjectsState>(
        builder: (context, state) {
          if (state is ContractorProjectsSingleLoading) {
            return const LoadingIndicator();
          }

          if (state is ContractorProjectsError) {
            return _buildErrorState(state.message);
          }

          if (state is ContractorProjectsLoaded &&
              state.selectedProject != null) {
            final project = state.selectedProject!;
            return _buildProjectDetail(project);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProjectDetail(ProjectModel project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(project),
          const SizedBox(height: 24),
          if (project.images.isNotEmpty) ...[
            _buildImageCarousel(project),
            const SizedBox(height: 24),
          ],
          _buildDescription(project),
          const SizedBox(height: 24),
          _buildProjectDetails(project),
          const SizedBox(height: 24),
          _buildLocationInfo(project),
          const SizedBox(height: 24),
          _buildRequirements(project),
          const SizedBox(height: 32),
          _buildBidButton(project),
        ],
      ),
    );
  }

  Widget _buildHeader(ProjectModel project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                StatusBadge(status: project.status),
              ],
            ),
            const SizedBox(height: 8),
            if (project.service != null)
              Text(
                project.service!.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: context.success,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${project.budget.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: context.success,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule,
                  color: context.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  project.frequency,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(ProjectModel project) {
    return ProjectImageCarousel(
      images:
          project.images.map((img) => AppUrls.getStorageUrl(img.path)).toList(),
      height: 200,
    );
  }

  Widget _buildDescription(ProjectModel project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetails(ProjectModel project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Key Factor', _formatKeyFactor(project.keyFactor)),
            if (project.startDate != null)
              _buildDetailRow(
                'Start Date',
                _formatDate(project.startDate!),
              ),
            if (project.endDate != null)
              _buildDetailRow(
                'End Date',
                _formatDate(project.endDate!),
              ),
            _buildDetailRow(
              'Posted',
              _formatDate(project.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(ProjectModel project) {
    final hasLocation = project.street != null ||
        project.city != null ||
        project.zipCode != null;

    if (!hasLocation) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatAddress(project),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirements(ProjectModel project) {
    if (project.additionalRequirements == null ||
        project.additionalRequirements!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Requirements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              project.additionalRequirements!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidButton(ProjectModel project) {
    final canBid = project.isInBidPhase();

    return BlocBuilder<ContractorProjectsBloc, ContractorProjectsState>(
      builder: (context, state) {
        // Check if user has already bid on this project
        bool userHasBid = false;
        if (state is ContractorProjectsLoaded && state.userHasBid != null) {
          userHasBid = state.userHasBid!;
        }

        if (!canBid) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.textSecondary.withOpacity(0.3),
                foregroundColor: context.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Bidding Closed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        // If user has already bid, show "Bid Submitted" status
        if (userHasBid) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: context.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.success),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: context.success),
                const SizedBox(width: 8),
                Text(
                  'Bid Submitted',
                  style: TextStyle(
                    color: context.success,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        // Show submit bid button
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showBidDialog(project),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit Bid',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Project',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  String _formatKeyFactor(String keyFactor) {
    return keyFactor
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAddress(ProjectModel project) {
    final parts = <String>[];
    if (project.street != null) parts.add(project.street!);
    if (project.city != null) parts.add(project.city!);
    if (project.zipCode != null) parts.add(project.zipCode!);
    return parts.join(', ');
  }

  void _showBidDialog(ProjectModel project) {
    // Navigate to the create bid page
    context.router.push(CreateBidRoute(project: project));
  }
}
