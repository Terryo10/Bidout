// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    ContractorDashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContractorDashboardPage(),
      );
    },
    CreateProjectRoute.name: (routeData) {
      final args = routeData.argsAs<CreateProjectRouteArgs>(
          orElse: () => const CreateProjectRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CreateProjectPage(
          key: args.key,
          preSelectedServiceId: args.preSelectedServiceId,
        ),
      );
    },
    EnhancedClientDashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const EnhancedClientDashboardPage(),
      );
    },
    ForgotPasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ForgotPasswordPage(),
      );
    },
    LandingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LandingPage(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    NotificationsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotificationsPage(),
      );
    },
    ProjectListingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProjectListingPage(),
      );
    },
    ProjectViewRoute.name: (routeData) {
      final args = routeData.argsAs<ProjectViewRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProjectViewPage(
          key: args.key,
          projectId: args.projectId,
        ),
      );
    },
    RegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegisterPage(),
      );
    },
  };
}

/// generated route for
/// [ContractorDashboardPage]
class ContractorDashboardRoute extends PageRouteInfo<void> {
  const ContractorDashboardRoute({List<PageRouteInfo>? children})
      : super(
          ContractorDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContractorDashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreateProjectPage]
class CreateProjectRoute extends PageRouteInfo<CreateProjectRouteArgs> {
  CreateProjectRoute({
    Key? key,
    int? preSelectedServiceId,
    List<PageRouteInfo>? children,
  }) : super(
          CreateProjectRoute.name,
          args: CreateProjectRouteArgs(
            key: key,
            preSelectedServiceId: preSelectedServiceId,
          ),
          initialChildren: children,
        );

  static const String name = 'CreateProjectRoute';

  static const PageInfo<CreateProjectRouteArgs> page =
      PageInfo<CreateProjectRouteArgs>(name);
}

class CreateProjectRouteArgs {
  const CreateProjectRouteArgs({
    this.key,
    this.preSelectedServiceId,
  });

  final Key? key;

  final int? preSelectedServiceId;

  @override
  String toString() {
    return 'CreateProjectRouteArgs{key: $key, preSelectedServiceId: $preSelectedServiceId}';
  }
}

/// generated route for
/// [EnhancedClientDashboardPage]
class EnhancedClientDashboardRoute extends PageRouteInfo<void> {
  const EnhancedClientDashboardRoute({List<PageRouteInfo>? children})
      : super(
          EnhancedClientDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'EnhancedClientDashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
      : super(
          ForgotPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ForgotPasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LandingPage]
class LandingRoute extends PageRouteInfo<void> {
  const LandingRoute({List<PageRouteInfo>? children})
      : super(
          LandingRoute.name,
          initialChildren: children,
        );

  static const String name = 'LandingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationsPage]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
      : super(
          NotificationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProjectListingPage]
class ProjectListingRoute extends PageRouteInfo<void> {
  const ProjectListingRoute({List<PageRouteInfo>? children})
      : super(
          ProjectListingRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProjectListingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProjectViewPage]
class ProjectViewRoute extends PageRouteInfo<ProjectViewRouteArgs> {
  ProjectViewRoute({
    Key? key,
    required int projectId,
    List<PageRouteInfo>? children,
  }) : super(
          ProjectViewRoute.name,
          args: ProjectViewRouteArgs(
            key: key,
            projectId: projectId,
          ),
          initialChildren: children,
        );

  static const String name = 'ProjectViewRoute';

  static const PageInfo<ProjectViewRouteArgs> page =
      PageInfo<ProjectViewRouteArgs>(name);
}

class ProjectViewRouteArgs {
  const ProjectViewRouteArgs({
    this.key,
    required this.projectId,
  });

  final Key? key;

  final int projectId;

  @override
  String toString() {
    return 'ProjectViewRouteArgs{key: $key, projectId: $projectId}';
  }
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(
          RegisterRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
