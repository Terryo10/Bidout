// lib/ui/dashboards/client_dashboard.dart (Updated with contractor directory integration)
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/services_bloc/services_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../routes/app_router.dart';
import '../widgets/service_card.dart';
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
                    context.router.push(const ContractorDirectoryRoute());
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Switch to Offering Services Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(AuthSwitchToContractorMode());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: context.colors.secondary,
                        foregroundColor: context.colors.onSecondary,
                      ),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Switch to Offering Services'),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                _QuickActionCard(
                  icon: Icons.subscriptions_outlined,
                  title: 'My Subscriptions',
                  color: context.colors.tertiary,
                  onTap: () {
                    // TODO: Implement navigation to subscriptions
                    context.router.push(const NotificationsRoute());
                  },
                ),
                const SizedBox(width: 16),
                _QuickActionCard(
                  icon: Icons.mark_chat_unread_outlined,
                  title: 'Message Requests',
                  color: context.colors.secondary,
                  onTap: () {
                    // TODO: Implement navigation to new requests
                    context.router.push(const NotificationsRoute());
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // My Projects Box
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  context.router.push(const ProjectListingRoute());
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderLight),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined,
                          size: 32, color: context.colors.primary),
                      const SizedBox(width: 16),
                      Text(
                        'My Projects',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: context.textSecondary),
                    ],
                  ),
                ),
              ),
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
          ],
        ),
      ),
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
