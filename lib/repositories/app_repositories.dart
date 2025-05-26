import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_blocs.dart';
import 'auth_repo/auth_provider.dart';
import 'auth_repo/auth_repository.dart';
import 'projects_repo/projects_provider.dart';
import 'projects_repo/projects_repository.dart';

class AppRepositories extends StatelessWidget {
  final FlutterSecureStorage storage;
  final AppBlocs appBlocs;

  const AppRepositories({
    super.key,
    required this.storage,
    required this.appBlocs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(
            storage: storage,
            authProvider: AuthProvider(storage: storage),
          ),
        ),
        RepositoryProvider(
          create: (context) => ProjectRepository(
            storage: storage,
            projectProvider: ProjectProvider(storage: storage),
          ),
        ),
        // Add other repositories here as needed
      ],
      child: appBlocs,
    );
  }
}