// lib/ui/landing/landing_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../routes/app_router.dart';

@RoutePage()
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const _LoadingView();
        } else if (state is AuthUnauthenticated) {
          return const _WelcomeView();
        } else if (state is AuthAuthenticated) {
          if (state.user.isClient) {
            context.router.replace(const EnhancedClientDashboardRoute());
          } else if (state.user.isContractor) {
            context.router.replace(const ContractorDashboardRoute());
          }
          return const _LoadingView();
        } else {
          return const _LoadingView();
        }
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary,
            context.colors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: context.colors.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'BidOut',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.colors.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(context.colors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary,
              context.colors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.construction,
                        size: 100,
                        color: context.colors.onPrimary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'BidOut',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: context.colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connect with the right contractors\nfor your projects',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: context.colors.onPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const _FeaturesList(),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ActionButton(
                        text: 'Get Started',
                        onPressed: () {
                          context.router.push(const RegisterRoute());
                        },
                        isPrimary: true,
                      ),
                      const SizedBox(height: 16),
                      _ActionButton(
                        text: 'Sign In',
                        onPressed: () {
                          context.router.push(const LoginRoute());
                        },
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  const _FeaturesList();

  @override
  Widget build(BuildContext context) {
    final features = [
      'Post projects and receive competitive bids',
      'Find qualified contractors in your area',
      'Secure payment and project management',
      'Real-time updates and communication',
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: context.colors.onPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    color: context.colors.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? context.colors.onPrimary : Colors.transparent,
          foregroundColor:
              isPrimary ? context.colors.primary : context.colors.onPrimary,
          side: isPrimary
              ? null
              : BorderSide(color: context.colors.onPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isPrimary ? 4 : 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
