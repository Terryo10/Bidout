import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../services/google_auth_service.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool showUserTypeDialog;
  final String? defaultUserType;

  const GoogleSignInButton({
    super.key,
    this.showUserTypeDialog = true,
    this.defaultUserType,
  });

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      // Get Google ID token
      final String? idToken = await GoogleAuthService.signInWithGoogle();

      if (idToken == null) {
        // User cancelled sign in
        return;
      }

      String? userType = defaultUserType;

      // Show user type selection if needed
      if (showUserTypeDialog && userType == null) {
        userType = await _showUserTypeDialog(context);
        if (userType == null) {
          // User cancelled user type selection
          return;
        }
      }

      // Default to client if no user type specified
      userType = userType ?? 'client';

      // Trigger Google Sign-In in AuthBloc
      if (context.mounted) {
        context.read<AuthBloc>().add(
              AuthGoogleSignInRequested(
                idToken: idToken,
                userType: userType,
              ),
            );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $error'),
            backgroundColor: context.error,
          ),
        );
      }
    }
  }

  Future<String?> _showUserTypeDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Account Type',
            style: TextStyle(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please select your account type to complete the sign-in process.',
                style: TextStyle(color: context.textSecondary),
              ),
              const SizedBox(height: 20),
              _UserTypeOption(
                title: 'Client',
                description: 'I need contractors for my projects',
                icon: Icons.business,
                onTap: () => Navigator.of(context).pop('client'),
              ),
              const SizedBox(height: 12),
              _UserTypeOption(
                title: 'Contractor',
                description: 'I provide services for projects',
                icon: Icons.construction,
                onTap: () => Navigator.of(context).pop('contractor'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: isLoading ? null : () => _handleGoogleSignIn(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.borderLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.g_mobiledata,
                        color: context.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _UserTypeOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _UserTypeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: context.borderLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: context.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
