// lib/ui/auth/login_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../routes/app_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/google_sign_in_button.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate based on user type
            if (state.user.isClient) {
              context.router.replace(const EnhancedClientDashboardRoute());
            } else if (state.user.isContractor) {
              context.router.replace(const ContractorDashboardRoute());
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.error,
              ),
            );
          }
        },
        child: Material(
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
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.router.pop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: context.colors.onPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Welcome Back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.colors.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter your credentials to access your account',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Email Field
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Enter your email address',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Enter your password',
                                obscureText: _obscurePassword,
                                prefixIcon: Icons.lock_outlined,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: context.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.router
                                        .push(const ForgotPasswordRoute());
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Login Button
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return LoadingButton(
                                    onPressed: _handleLogin,
                                    isLoading: state is AuthLoading,
                                    text: 'Sign In',
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                      child:
                                          Divider(color: context.borderLight)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                          color: context.textSecondary),
                                    ),
                                  ),
                                  Expanded(
                                      child:
                                          Divider(color: context.borderLight)),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Social Login Buttons
                              const GoogleSignInButton(),
                              const SizedBox(height: 16),
                              _SocialLoginButton(
                                icon: Icons.facebook,
                                text: 'Continue with Facebook',
                                onPressed: () {
                                  // TODO: Implement Facebook login
                                },
                              ),

                              const Spacer(),

                              // Sign Up Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t have an account? ',
                                    style:
                                        TextStyle(color: context.textSecondary),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.router.replace(RegisterRoute());
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: context.colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: context.textSecondary),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
