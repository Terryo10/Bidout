// lib/ui/dashboards/client_dashboard.dart (Updated with contractor directory integration)
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/projects_bloc/project_bloc.dart';
import '../../bloc/services_bloc/services_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/contractor/contractor_model.dart';
import '../../models/services/service_model.dart' as service;
import '../../repositories/contractor_repo/contractor_repo.dart';
import '../../repositories/projects_repo/projects_repository.dart';
import '../../routes/app_router.dart';
import '../widgets/action_card.dart';
import '../widgets/project_preview_card.dart';
import '../widgets/service_card.dart';
import '../widgets/contractor_card.dart';
import '../widgets/theme_toggle.dart';

@RoutePage(name: 'EnhancedClientDashboardRoute')
class EnhancedClientDashboardPage extends StatelessWidget {
  const EnhancedClientDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.router.replace(LandingRoute());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            const ThemeToggle(),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                context.router.push(NotificationsRoute());
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: context.textSecondary),
                      const SizedBox(width: 8),
                      const Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: context.error),
                      const SizedBox(width: 8),
                      const Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: const _DashboardContent(),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ServicesBloc>().add(ServicesLoadRequested());
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
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary,
                    context.colors.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your projects and find contractors',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _QuickActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'New Project',
                  color: context.colors.primary,
                  onTap: () {
                    context.router.push(CreateProjectRoute());
                  },
                ),
                const SizedBox(width: 16),
                _QuickActionCard(
                  icon: Icons.search,
                  title: 'Find Contractors',
                  color: context.colors.secondary,
                  onTap: () {
                    context.router.push(ContractorDirectoryRoute());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _QuickActionCard(
                  icon: Icons.pending_actions,
                  title: 'Pending Bids',
                  color: context.warning,
                  onTap: () {
                    context.router.push(ProjectListingRoute());
                  },
                ),
                const SizedBox(width: 16),
                _QuickActionCard(
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  color: context.info,
                  onTap: () {
                    // TODO: Analytics route not implemented yet
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Services Section
            Text(
              'Available Services',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
                if (state is ServicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ServicesError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: context.error),
                    ),
                  );
                }
                if (state is ServicesLoaded) {
                  return SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.services.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final service = state.services[index];
                        return ServiceCard(
                          serviceModel: service,
                          onTap: () {
                            context.router.push(CreateProjectRoute(
                                preSelectedServiceId: service.id));
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // Project Stats
            Text(
              'Project Statistics',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(context),

            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Active Projects',
          value: '5',
          icon: Icons.work_outline,
          color: context.colors.primary,
        ),
        _StatCard(
          title: 'Total Bids',
          value: '12',
          icon: Icons.gavel,
          color: context.warning,
        ),
        _StatCard(
          title: 'Completed',
          value: '8',
          icon: Icons.check_circle_outline,
          color: context.success,
        ),
        _StatCard(
          title: 'In Review',
          value: '3',
          icon: Icons.rate_review_outlined,
          color: context.info,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _ActivityCard(
          title: 'Project Bid Received',
          description: 'New bid for Kitchen Renovation project',
          time: '2 hours ago',
          icon: Icons.gavel,
          color: context.colors.primary,
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
