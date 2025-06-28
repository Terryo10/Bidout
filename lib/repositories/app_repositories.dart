import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_blocs.dart';
import 'auth_repo/auth_provider.dart';
import 'auth_repo/auth_repository.dart';
import 'contractor_repo/contractor_provider.dart';
import 'contractor_repo/contractor_repo.dart';
import 'projects_repo/projects_provider.dart';
import 'projects_repo/projects_repository.dart';
import 'subscription_repo/subscription_provider.dart';
import 'subscription_repo/subscription_repository.dart';
import 'service_requests_repo/service_requests_provider.dart';
import 'service_requests_repo/service_requests_repository.dart';

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
        RepositoryProvider(
          create: (context) => ContractorRepository(
            storage: storage,
            contractorProvider: ContractorProvider(storage: storage),
          ),
        ),
        RepositoryProvider(
          create: (context) => SubscriptionRepository(
            storage: storage,
            subscriptionProvider: SubscriptionProvider(storage: storage),
          ),
        ),
        RepositoryProvider(
          create: (context) => ServiceRequestsRepository(
            storage: storage,
            serviceRequestsProvider: ServiceRequestsProvider(storage: storage),
          ),
        ),
        // Add other repositories here as needed
      ],
      child: appBlocs,
    );
  }
}
