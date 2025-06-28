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
    ClientServiceRequestsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ClientServiceRequestsPage(),
      );
    },
    ContractorDashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContractorDashboardPage(),
      );
    },
    ContractorDetailRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ContractorDetailRouteArgs>(
          orElse: () =>
              ContractorDetailRouteArgs(contractorId: pathParams.getInt('id')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ContractorDetailPage(
          key: args.key,
          contractorId: args.contractorId,
        ),
      );
    },
    ContractorDirectoryRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContractorDirectoryPage(),
      );
    },
    ContractorPreviewRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ContractorPreviewRouteArgs>(
          orElse: () => ContractorPreviewRouteArgs(
              contractorId: pathParams.getInt('id')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ContractorPreviewPage(
          key: args.key,
          contractorId: args.contractorId,
        ),
      );
    },
    ContractorProfileRoute.name: (routeData) {
      final args = routeData.argsAs<ContractorProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ContractorProfilePage(
          key: args.key,
          contractorId: args.contractorId,
        ),
      );
    },
    ContractorServiceRequestsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContractorServiceRequestsPage(),
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
    FindContractorsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FindContractorsPage(),
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
    PaymentSuccessRoute.name: (routeData) {
      final args = routeData.argsAs<PaymentSuccessRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PaymentSuccessScreen(
          key: args.key,
          type: args.type,
          packageName: args.packageName,
          amount: args.amount,
          bidCount: args.bidCount,
          details: args.details,
        ),
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
          project: args.project,
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
/// [ClientServiceRequestsPage]
class ClientServiceRequestsRoute extends PageRouteInfo<void> {
  const ClientServiceRequestsRoute({List<PageRouteInfo>? children})
      : super(
          ClientServiceRequestsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ClientServiceRequestsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
/// [ContractorDetailPage]
class ContractorDetailRoute extends PageRouteInfo<ContractorDetailRouteArgs> {
  ContractorDetailRoute({
    Key? key,
    required int contractorId,
    List<PageRouteInfo>? children,
  }) : super(
          ContractorDetailRoute.name,
          args: ContractorDetailRouteArgs(
            key: key,
            contractorId: contractorId,
          ),
          rawPathParams: {'id': contractorId},
          initialChildren: children,
        );

  static const String name = 'ContractorDetailRoute';

  static const PageInfo<ContractorDetailRouteArgs> page =
      PageInfo<ContractorDetailRouteArgs>(name);
}

class ContractorDetailRouteArgs {
  const ContractorDetailRouteArgs({
    this.key,
    required this.contractorId,
  });

  final Key? key;

  final int contractorId;

  @override
  String toString() {
    return 'ContractorDetailRouteArgs{key: $key, contractorId: $contractorId}';
  }
}

/// generated route for
/// [ContractorDirectoryPage]
class ContractorDirectoryRoute extends PageRouteInfo<void> {
  const ContractorDirectoryRoute({List<PageRouteInfo>? children})
      : super(
          ContractorDirectoryRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContractorDirectoryRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ContractorPreviewPage]
class ContractorPreviewRoute extends PageRouteInfo<ContractorPreviewRouteArgs> {
  ContractorPreviewRoute({
    Key? key,
    required int contractorId,
    List<PageRouteInfo>? children,
  }) : super(
          ContractorPreviewRoute.name,
          args: ContractorPreviewRouteArgs(
            key: key,
            contractorId: contractorId,
          ),
          rawPathParams: {'id': contractorId},
          initialChildren: children,
        );

  static const String name = 'ContractorPreviewRoute';

  static const PageInfo<ContractorPreviewRouteArgs> page =
      PageInfo<ContractorPreviewRouteArgs>(name);
}

class ContractorPreviewRouteArgs {
  const ContractorPreviewRouteArgs({
    this.key,
    required this.contractorId,
  });

  final Key? key;

  final int contractorId;

  @override
  String toString() {
    return 'ContractorPreviewRouteArgs{key: $key, contractorId: $contractorId}';
  }
}

/// generated route for
/// [ContractorProfilePage]
class ContractorProfileRoute extends PageRouteInfo<ContractorProfileRouteArgs> {
  ContractorProfileRoute({
    Key? key,
    required int contractorId,
    List<PageRouteInfo>? children,
  }) : super(
          ContractorProfileRoute.name,
          args: ContractorProfileRouteArgs(
            key: key,
            contractorId: contractorId,
          ),
          initialChildren: children,
        );

  static const String name = 'ContractorProfileRoute';

  static const PageInfo<ContractorProfileRouteArgs> page =
      PageInfo<ContractorProfileRouteArgs>(name);
}

class ContractorProfileRouteArgs {
  const ContractorProfileRouteArgs({
    this.key,
    required this.contractorId,
  });

  final Key? key;

  final int contractorId;

  @override
  String toString() {
    return 'ContractorProfileRouteArgs{key: $key, contractorId: $contractorId}';
  }
}

/// generated route for
/// [ContractorServiceRequestsPage]
class ContractorServiceRequestsRoute extends PageRouteInfo<void> {
  const ContractorServiceRequestsRoute({List<PageRouteInfo>? children})
      : super(
          ContractorServiceRequestsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContractorServiceRequestsRoute';

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
/// [FindContractorsPage]
class FindContractorsRoute extends PageRouteInfo<void> {
  const FindContractorsRoute({List<PageRouteInfo>? children})
      : super(
          FindContractorsRoute.name,
          initialChildren: children,
        );

  static const String name = 'FindContractorsRoute';

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
/// [PaymentSuccessScreen]
class PaymentSuccessRoute extends PageRouteInfo<PaymentSuccessRouteArgs> {
  PaymentSuccessRoute({
    Key? key,
    required String type,
    required String packageName,
    required double amount,
    int? bidCount,
    Map<String, dynamic>? details,
    List<PageRouteInfo>? children,
  }) : super(
          PaymentSuccessRoute.name,
          args: PaymentSuccessRouteArgs(
            key: key,
            type: type,
            packageName: packageName,
            amount: amount,
            bidCount: bidCount,
            details: details,
          ),
          initialChildren: children,
        );

  static const String name = 'PaymentSuccessRoute';

  static const PageInfo<PaymentSuccessRouteArgs> page =
      PageInfo<PaymentSuccessRouteArgs>(name);
}

class PaymentSuccessRouteArgs {
  const PaymentSuccessRouteArgs({
    this.key,
    required this.type,
    required this.packageName,
    required this.amount,
    this.bidCount,
    this.details,
  });

  final Key? key;

  final String type;

  final String packageName;

  final double amount;

  final int? bidCount;

  final Map<String, dynamic>? details;

  @override
  String toString() {
    return 'PaymentSuccessRouteArgs{key: $key, type: $type, packageName: $packageName, amount: $amount, bidCount: $bidCount, details: $details}';
  }
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
    ProjectModel? project,
    List<PageRouteInfo>? children,
  }) : super(
          ProjectViewRoute.name,
          args: ProjectViewRouteArgs(
            key: key,
            projectId: projectId,
            project: project,
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
    this.project,
  });

  final Key? key;

  final int projectId;

  final ProjectModel? project;

  @override
  String toString() {
    return 'ProjectViewRouteArgs{key: $key, projectId: $projectId, project: $project}';
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
