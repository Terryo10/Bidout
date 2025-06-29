import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../models/projects/project_model.dart';
import '../ui/auth/forgot_password_page.dart';
import '../ui/auth/login_page.dart';
import '../ui/auth/register_page.dart';
import '../ui/contractor/contractor_directory_page.dart';
import '../ui/contractor/profile/contractor_profile_page.dart';
import '../ui/contractor/bids/contractor_bids_page.dart';
import '../ui/contractor/bids/create_bid_page.dart';
import '../ui/dashboards/client_dashboard.dart';
import '../ui/dashboards/contractor_dashboard_page.dart';
import '../ui/find_contractors/contractor_detail_page.dart';
import '../ui/find_contractors/find_contractors.dart';
import '../ui/find_contractors/contractor_preview_page.dart';
import '../ui/landing/landing_page.dart';
import '../ui/notifications/notifications_page.dart';
import '../ui/projects/create_project_page.dart';
import '../ui/projects/project_listing_page.dart';
import '../ui/projects/project_view_page.dart';
import '../ui/projects/project_bids_page.dart';
import '../ui/service_requests/client_service_requests_page.dart';
import '../ui/service_requests/contractor_service_requests_page.dart';
import '../ui/subscription/payment_success_screen.dart';
import '../ui/profile/client_profile/client_profile_page.dart';
import '../ui/profile/contractor_profile/contractor_profile_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
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

        // Dashboard routes
        AutoRoute(
          page: ContractorDashboardRoute.page,
          path: '/contractor-dashboard',
        ),
        AutoRoute(
          page: EnhancedClientDashboardRoute.page,
          path: '/client-dashboard',
        ),

        // Project routes
        AutoRoute(
          page: CreateProjectRoute.page,
          path: '/projects/create',
        ),
        AutoRoute(
          page: ProjectViewRoute.page,
          path: '/projects/:id',
        ),
        AutoRoute(
          page: ProjectListingRoute.page,
          path: '/projects',
        ),
        AutoRoute(
          page: ProjectBidsRoute.page,
          path: '/projects/:id/bids',
        ),

        // Bid routes
        AutoRoute(
          page: CreateBidRoute.page,
          path: '/projects/:id/bid/create',
        ),

        // Find contractors route
        AutoRoute(
          page: ContractorDirectoryRoute.page,
          path: '/find-contractors',
        ),

        // Contractor routes
        AutoRoute(
          page: ContractorProfileRoute.page,
          path: '/contractors/:id',
        ),
        AutoRoute(
          page: ContractorPreviewRoute.page,
          path: '/contractors/:id/preview',
        ),
        AutoRoute(
          page: ContractorBidsRoute.page,
          path: '/contractor/bids',
        ),

        // Notifications route
        AutoRoute(
          page: NotificationsRoute.page,
          path: '/notifications',
        ),

        // Service Requests routes
        AutoRoute(
          page: ClientServiceRequestsRoute.page,
          path: '/client/service-requests',
        ),
        AutoRoute(
          page: ContractorServiceRequestsRoute.page,
          path: '/contractor/service-requests',
        ),

        // Profile routes
        AutoRoute(
          page: ClientProfileRoute.page,
          path: '/client/profile',
        ),
        AutoRoute(
          page: EditContractorProfileRoute.page,
          path: '/contractor/profile',
        ),
      ];
}
