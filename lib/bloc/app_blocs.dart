// lib/bloc/app_blocs.dart
import 'package:bidout/bloc/services_bloc/services_bloc.dart';
import 'package:bidout/repositories/projects_repo/projects_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../repositories/auth_repo/auth_provider.dart';
import '../repositories/auth_repo/auth_repository.dart';
import '../repositories/projects_repo/projects_provider.dart';
import '../repositories/contractor_repo/contractor_provider.dart';
import '../repositories/contractor_repo/contractor_repo.dart';
import '../repositories/subscription_repo/subscription_provider.dart';
import '../repositories/subscription_repo/subscription_repository.dart';
import '../repositories/service_requests_repo/service_requests_provider.dart';
import '../repositories/service_requests_repo/service_requests_repository.dart';
import '../repositories/contractor_projects_repo/contractor_projects_repository.dart';
import '../repositories/contractor_projects_repo/contractor_projects_provider.dart';
import '../repositories/profile_repo/profile_repository.dart';
import '../repositories/profile_repo/profile_provider.dart';
import '../repositories/bids_repo/bids_repository.dart';
import '../repositories/bids_repo/bids_provider.dart';
import 'auth_bloc/auth_bloc.dart';
import 'contractor_projects_bloc/contractor_projects_bloc.dart';
import 'projects_bloc/project_bloc.dart';
import 'notifications_bloc/notifications_bloc.dart';
import 'contractor_bloc/contractor_bloc.dart';
import 'subscription_bloc/subscription_bloc.dart';
import 'service_requests_bloc/service_requests_bloc.dart';
import 'profile_bloc/profile_bloc.dart';
import 'theme_bloc/theme_bloc.dart';
import 'bids_bloc/bids_bloc.dart';

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProjectRepository>(
          create: (context) => ProjectRepository(
            storage: storage,
            projectProvider: ProjectProvider(storage: storage),
          ),
        ),
        RepositoryProvider<ContractorRepository>(
          create: (context) => ContractorRepository(
            storage: storage,
            contractorProvider: ContractorProvider(storage: storage),
          ),
        ),
        RepositoryProvider<SubscriptionRepository>(
          create: (context) => SubscriptionRepository(
            storage: storage,
            subscriptionProvider: SubscriptionProvider(storage: storage),
          ),
        ),
        RepositoryProvider<ServiceRequestsRepository>(
          create: (context) => ServiceRequestsRepository(
            storage: storage,
            serviceRequestsProvider: ServiceRequestsProvider(storage: storage),
          ),
        ),
        RepositoryProvider<ContractorProjectsRepository>(
          create: (context) => ContractorProjectsRepository(
            storage: storage,
            contractorProjectsProvider:
                ContractorProjectsProvider(storage: storage),
          ),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(
            storage: storage,
            profileProvider: ProfileProvider(storage: storage),
          ),
        ),
        RepositoryProvider<BidsRepository>(
          create: (context) => BidsRepository(
            storage: storage,
            bidsProvider: BidsProvider(storage: storage),
          ),
        ),
      ],
      child: MultiBlocProvider(
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
              projectRepository:
                  RepositoryProvider.of<ProjectRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => NotificationsBloc(),
          ),
          BlocProvider(
            lazy: false, // This will make the bloc initialize immediately
            create: (context) {
              final bloc = ServicesBloc(
                projectRepository:
                    RepositoryProvider.of<ProjectRepository>(context),
              );
              // Load services immediately
              bloc.add(ServicesLoadRequested());
              return bloc;
            },
          ),
          BlocProvider(
            create: (context) => ContractorBloc(
              contractorRepository:
                  RepositoryProvider.of<ContractorRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => SubscriptionBloc(
              subscriptionRepository:
                  RepositoryProvider.of<SubscriptionRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => ServiceRequestsBloc(
              serviceRequestsRepository:
                  RepositoryProvider.of<ServiceRequestsRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => ContractorProjectsBloc(
              contractorProjectsRepository:
                  RepositoryProvider.of<ContractorProjectsRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(
              profileRepository:
                  RepositoryProvider.of<ProfileRepository>(context),
            ),
          ),
          BlocProvider(
            lazy: false,
            create: (context) {
              final bloc = ThemeBloc(storage: storage);
              bloc.add(LoadTheme());
              return bloc;
            },
          ),
          BlocProvider(
            create: (context) => BidsBloc(
              bidsRepository: RepositoryProvider.of<BidsRepository>(context),
            ),
          ),
          // Add other BLoCs here as needed
        ],
        child: app,
      ),
    );
  }
}
