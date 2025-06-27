// lib/ui/dashboard/contractor_dashboard_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../routes/app_router.dart';
import '../widgets/action_card.dart';
import '../widgets/theme_toggle.dart';

@RoutePage()
class ContractorDashboardPage extends StatelessWidget {
  const ContractorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.router.replace(LandingRoute());
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.error,
            ),
          );
        } else if (state is AuthAuthenticated && state.user.isClient) {
          context.router.replace(EnhancedClientDashboardRoute());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contractor Dashboard'),
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
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return _ContractorDashboardContent(user: state.user);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _ContractorDashboardContent extends StatelessWidget {
  final dynamic user;

  const _ContractorDashboardContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  context.colors.secondary,
                  context.colors.secondary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user.name}!',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colors.onSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to find your next project?',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Status Banner
          if (user.contractorStatus == 'pending')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.warning),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, color: context.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your contractor profile is pending approval. You\'ll be notified once it\'s approved.',
                      style: TextStyle(color: context.warning),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Switch to Client Mode Button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(AuthSwitchToClientMode());
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                        ),
                        icon: const Icon(Icons.swap_horiz),
                        label: Text(
                          state.user.hasClientRole
                              ? 'Switch to Client Mode'
                              : 'Start Using Client Features',
                        ),
                      ),
                    ),
                    if (!state.user.hasClientRole)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Click to set up your client profile',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: context.textTheme.titleLarge,
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
                icon: Icons.search,
                title: 'Browse Projects',
                subtitle: 'Find new opportunities',
                color: context.colors.secondary,
                onTap: () {
                  // TODO: Navigate to browse projects
                },
              ),
              ActionCard(
                icon: Icons.assignment,
                title: 'My Bids',
                subtitle: 'View submitted bids',
                color: context.colors.primary,
                onTap: () {
                  // TODO: Navigate to my bids
                },
              ),
              ActionCard(
                icon: Icons.account_circle,
                title: 'Profile',
                subtitle: 'Update your profile',
                color: context.info,
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
              ActionCard(
                icon: Icons.payment,
                title: 'Billing',
                subtitle: 'Manage subscription',
                color: context.warning,
                onTap: () {
                  // TODO: Navigate to billing
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.borderLight),
            ),
            child: Center(
              child: Text(
                'No recent activity. Start bidding on projects!',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
