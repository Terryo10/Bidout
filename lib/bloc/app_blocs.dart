import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
        // Add your BlocProviders here
        // Example:
        // BlocProvider(
        //   create: (context) => AuthBloc(storage: storage),
        // ),
      ],
      child: app,
    );
  }
}
