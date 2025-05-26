// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'bloc/app_blocs.dart';
import 'constants/app_colors.dart';
import 'repositories/app_repositories.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const FlutterSecureStorage storage = FlutterSecureStorage();
  final appRouter = AppRouter();

  runApp(BidOutApp(
    storage: storage,
    appRouter: appRouter,
  ));
}

class BidOutApp extends StatelessWidget {
  final FlutterSecureStorage storage;
  final AppRouter appRouter;

  const BidOutApp({
    super.key,
    required this.storage,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return AppRepositories(
      storage: storage,
      appBlocs: AppBlocs(
        storage: storage,
        app: MaterialApp.router(
          title: 'BidOut',
          routerConfig: appRouter.config(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}