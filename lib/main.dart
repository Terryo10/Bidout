// lib/main.dart (Enhanced version)
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/app_blocs.dart';
import 'bloc/theme_bloc/theme_bloc.dart';
import 'constants/app_theme.dart';
import 'repositories/app_repositories.dart';
import 'routes/app_router.dart';
import 'services/stripe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  await StripeService.init();

  // Configure secure storage options
  FlutterSecureStorage storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

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
        app: BlocProvider(
          create: (context) => ThemeBloc(storage: storage)..add(LoadTheme()),
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                title: 'BidOut',
                routerConfig: appRouter.config(),
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0, // Prevent text scaling issues
                    ),
                    child: child!,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
