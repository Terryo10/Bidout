import 'package:auto_route/auto_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Add your routes here
        // Example:
        // AutoRoute(page: LandingRoute.page, initial: true),
      ];
}
