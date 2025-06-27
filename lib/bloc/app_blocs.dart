// lib/bloc/app_blocs.dart
import 'package:bidout/bloc/services_bloc/services_bloc.dart';
import 'package:bidout/repositories/projects_repo/projects_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../repositories/auth_repo/auth_provider.dart';
import '../repositories/auth_repo/auth_repository.dart';
import '../repositories/projects_repo/projects_provider.dart';
import 'auth_bloc/auth_bloc.dart';
import 'projects_bloc/project_bloc.dart';
import 'notifications_bloc/notifications_bloc.dart';

class AppBlocs extends StatelessWidget {
  final Widget app;
  final FlutterSecureStorage storage;

  const AppBlocs({
    super.key,
    required this.app,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    // Create repositories that will be shared
    final projectRepository = ProjectRepository(
      storage: storage,
      projectProvider: ProjectProvider(storage: storage),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(
              storage: storage,
              authProvider: AuthProvider(storage: storage),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => ProjectBloc(
            projectRepository: projectRepository,
          ),
        ),
        BlocProvider(
          create: (context) => NotificationsBloc(),
        ),
        BlocProvider(
          lazy: false, // This will make the bloc initialize immediately
          create: (context) {
            final bloc = ServicesBloc(projectRepository: projectRepository);
            // Load services immediately
            bloc.add(ServicesLoadRequested());
            return bloc;
          },
        ),
        // Add other BLoCs here as needed
      ],
      child: app,
    );
  }
}
