import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../ui/auth/forgot_password_page.dart';
import '../ui/auth/login_page.dart';
import '../ui/auth/register_page.dart';

import '../ui/dashboards/client_dashboard.dart';
import '../ui/dashboards/contractor_dashboard_page.dart';
import '../ui/landing/landing_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Landing page - initial route
    AutoRoute(
      page: LandingRoute.page,
      path: '/',
      initial: true,
    ),
    
    // Auth routes
    AutoRoute(
      page: LoginRoute.page,
      path: '/login',
    ),
    AutoRoute(
      page: RegisterRoute.page,
      path: '/register',
    ),
    AutoRoute(
      page: ForgotPasswordRoute.page,
      path: '/forgot-password',
    ),
    
    // Dashboard routes
    AutoRoute(
      page: ClientDashboardRoute.page,
      path: '/client-dashboard',
    ),
    AutoRoute(
      page: ContractorDashboardRoute.page,
      path: '/contractor-dashboard',
    ),
  ];
}