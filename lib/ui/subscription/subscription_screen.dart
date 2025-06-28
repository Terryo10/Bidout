import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../constants/app_theme_extension.dart';
import 'client_subscription_screen.dart';
import 'contractor_subscription_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;

          // Route to appropriate subscription screen based on active role
          if (user.isContractor) {
            return const ContractorSubscriptionScreen();
          } else if (user.isClient) {
            return const ClientSubscriptionScreen();
          } else {
            return _buildRoleSelectionScreen(context, user.availableRoles);
          }
        }

        // If not authenticated, show error state
        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscription'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
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
                  'Authentication Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please log in to access subscription features',
                  style: TextStyle(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleSelectionScreen(
      BuildContext context, List<String> availableRoles) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: context.colors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Select Your Role',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your role to view the appropriate subscription plans',
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (availableRoles.contains('client'))
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.colors.primary,
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text(
                    'Client',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Post projects and hire contractors'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.read<AuthBloc>().add(AuthSwitchToClientMode());
                  },
                ),
              ),
            if (availableRoles.contains('contractor'))
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: const Icon(
                      Icons.construction,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text(
                    'Contractor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle:
                      const Text('Bid on projects and grow your business'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.read<AuthBloc>().add(AuthSwitchToContractorMode());
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
