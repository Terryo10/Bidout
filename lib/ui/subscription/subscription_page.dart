import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/subscription_bloc/subscription_bloc.dart';
import '../../repositories/subscription_repo/subscription_repository.dart';
import 'subscription_screen.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc(
        subscriptionRepository:
            RepositoryProvider.of<SubscriptionRepository>(context),
      ),
      child: const SubscriptionScreen(),
    );
  }
}
