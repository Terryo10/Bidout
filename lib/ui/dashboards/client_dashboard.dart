// lib/ui/dashboards/enhanced_client_dashboard.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../constants/app_colors.dart';
import '../../models/services/service_model.dart' as service;
import '../../repositories/projects_repo/projects_repository.dart';
import '../../routes/app_router.dart';
import '../widgets/action_card.dart';
import '../widgets/project_preview_card.dart';
import '../widgets/service_card.dart';

@RoutePage()
class EnhancedClientDashboardPage extends StatefulWidget {
  const EnhancedClientDashboardPage({super.key});

  @override
  State<EnhancedClientDashboardPage> createState() =>
      _EnhancedClientDashboardPageState();
}

class _EnhancedClientDashboardPageState
    extends State<EnhancedClientDashboardPage> {
  List<service.ServiceModel> _services = [];
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final projectRepository = context.read<ProjectRepository>();
      final services = await projectRepository.getServices();
      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.router.replace(const LandingRoute());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: Navigate to notifications
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return _EnhancedClientDashboardContent(
                user: state.user,
                services: _services,
                isLoadingServices: _isLoadingServices,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _EnhancedClientDashboardContent extends StatelessWidget {
  final dynamic user;
  final List<service.ServiceModel> services;
  final bool isLoadingServices;

  const _EnhancedClientDashboardContent({
    required this.user,
    required this.services,
    required this.isLoadingServices,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh functionality
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user.name}!',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ready to post your next project?',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.router.push(CreateProjectRoute());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Create Project'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Services Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all services
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Services Horizontal List
            if (isLoadingServices)
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (services.isEmpty)
              Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Center(
                  child: Text(
                    'No services available',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < services.length - 1 ? 16 : 0,
                      ),
                      child: ServiceCard(
                        serviceModel: service,
                        onTap: () {
                          // Navigate to create project with this service pre-selected
                          context.router.push(CreateProjectRoute(
                              preSelectedServiceId: service.id));
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                ActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Post Project',
                  subtitle: 'Create a new project',
                  color: AppColors.primary,
                  onTap: () {
                    context.router.push(CreateProjectRoute());
                  },
                ),
                ActionCard(
                  icon: Icons.folder_open,
                  title: 'My Projects',
                  subtitle: 'View all projects',
                  color: AppColors.secondary,
                  onTap: () {
                    // TODO: Navigate to projects
                  },
                ),
                ActionCard(
                  icon: Icons.people,
                  title: 'Find Contractors',
                  subtitle: 'Browse contractors',
                  color: AppColors.warning,
                  onTap: () {
                    // TODO: Navigate to contractors
                  },
                ),
                ActionCard(
                  icon: Icons.payment,
                  title: 'Billing',
                  subtitle: 'Manage subscription',
                  color: AppColors.info,
                  onTap: () {
                    // TODO: Navigate to billing
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Projects Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Projects',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all projects
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent Projects List
            // TODO: Replace with actual projects data
            _buildRecentProjectsSection(),

            const SizedBox(height: 24),

            // Statistics Cards
            const Text(
              'Project Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Projects',
                    '3',
                    Icons.work_outline,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Bids',
                    '24',
                    Icons.assignment_turned_in,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '8',
                    Icons.check_circle_outline,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Spent',
                    '\$12,450',
                    Icons.monetization_on,
                    AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProjectsSection() {
    // Mock data - replace with actual projects
    final recentProjects = [
      {
        'title': 'Kitchen Renovation',
        'service': 'Home Improvement',
        'budget': 15000,
        'status': 'In Progress',
        'bidsCount': 5,
        'image': null,
      },
      {
        'title': 'Logo Design',
        'service': 'Graphic Design',
        'budget': 500,
        'status': 'Open for Bids',
        'bidsCount': 12,
        'image': null,
      },
      {
        'title': 'Website Development',
        'service': 'Web Development',
        'budget': 3000,
        'status': 'Completed',
        'bidsCount': 8,
        'image': null,
      },
    ];

    if (recentProjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.folder_open,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first project to get started',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // context.router.push(const CreateProjectRoute());
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentProjects.map((project) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProjectPreviewCard(
            title: project['title'] as String,
            service: project['service'] as String,
            budget: project['budget'] as int,
            status: project['status'] as String,
            bidsCount: project['bidsCount'] as int,
            imageUrl: project['image'] as String?,
            onTap: () {
              // TODO: Navigate to project details
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(
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
              const Spacer(),
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
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
