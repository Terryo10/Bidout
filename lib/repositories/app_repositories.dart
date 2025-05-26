import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_blocs.dart';

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
        // Add your RepositoryProviders here
        // Example:
        // RepositoryProvider(
        //   create: (context) => AuthRepository(storage: storage),
        // ),
      ],
      child: appBlocs,
    );
  }
}
