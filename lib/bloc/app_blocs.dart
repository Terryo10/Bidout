// lib/bloc/app_blocs.dart
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
            projectRepository: ProjectRepository(
              storage: storage,
              projectProvider: ProjectProvider(storage: storage),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => NotificationsBloc(),
        ),
        // Add other BLoCs here as needed
      ],
      child: app,
    );
  }
}
