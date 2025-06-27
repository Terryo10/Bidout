// lib/ui/contractor/
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/contractor_bloc/contractor_bloc.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme_extension.dart';
import '../../constants/app_urls.dart';
import '../../models/contractor/contractor_model.dart';
import '../widgets/contractor_info_section.dart';
import '../widgets/contractor_portfolio_preview.dart';
import '../widgets/contractor_services_section.dart';
import '../widgets/contractor_stats_section.dart';

@RoutePage()
class ContractorDetailPage extends StatefulWidget {
  final int contractorId;

  const ContractorDetailPage({
    super.key,
    @PathParam('id') required this.contractorId,
  });

  @override
  State<ContractorDetailPage> createState() => _ContractorDetailPageState();
}

class _ContractorDetailPageState extends State<ContractorDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ContractorBloc>().add(
          ContractorSingleLoadRequested(contractorId: widget.contractorId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContractorBloc, ContractorState>(
      listener: (context, state) {
        if (state is ContractorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ContractorLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is ContractorError) {
          return Scaffold(
            body: Center(
              child: Text(state.message),
            ),
          );
        }

        if (state is ContractorSingleLoaded) {
          final contractor = state.contractor;
          return _buildContractorDetails(contractor);
        }

        return const Scaffold(
          body: Center(
            child: Text('Something went wrong'),
          ),
        );
      },
    );
  }

  Widget _buildContractorDetails(ContractorModel contractor) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                contractor.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.colors.primary,
                      context.colors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: contractor.avatar != null
                            ? NetworkImage(
                                AppUrls.getStorageUrl(contractor.avatar))
                            : null,
                        backgroundColor:
                            context.colors.onPrimary.withOpacity(0.2),
                        child: contractor.avatar == null
                            ? Text(
                                contractor.name.isNotEmpty
                                    ? contractor.name[0].toUpperCase()
                                    : 'C',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: context.colors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      if (contractor.businessName != null)
                        Text(
                          contractor.businessName!,
                          style: TextStyle(
                            color: context.colors.onPrimary,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareContractor(contractor),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'contact':
                      _contactContractor(contractor);
                      break;
                    case 'report':
                      _reportContractor(contractor);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'contact',
                    child: Row(
                      children: [
                        Icon(Icons.contact_mail, size: 20),
                        SizedBox(width: 8),
                        Text('Contact'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report, size: 20),
                        SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Section
                ContractorStatsSection(contractor: contractor),
                const SizedBox(height: 24),

                // Services Section
                ContractorServicesSection(contractor: contractor),
                const SizedBox(height: 24),

                // Info Section
                ContractorInfoSection(contractor: contractor),
                const SizedBox(height: 24),

                // Portfolio Preview
                if (contractor.featuredPortfolios.isNotEmpty)
                  ContractorPortfolioPreview(contractor: contractor),

                const SizedBox(height: 24),

                // Contact Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _contactContractor(contractor),
                    icon: const Icon(Icons.contact_mail),
                    label: const Text('Contact Contractor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Space for FAB
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _shareContractor(ContractorModel contractor) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality not implemented yet')),
    );
  }

  void _contactContractor(ContractorModel contractor) {
    // Show contact options modal
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact ${contractor.displayName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (contractor.email.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.email, color: AppColors.primary),
                title: const Text('Send Email'),
                subtitle: Text(contractor.email),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open email app
                },
              ),
            if (contractor.phone != null)
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.success),
                title: const Text('Call'),
                subtitle: Text(contractor.phone!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open phone app
                },
              ),
            if (contractor.website != null)
              ListTile(
                leading: const Icon(Icons.web, color: AppColors.info),
                title: const Text('Visit Website'),
                subtitle: Text(contractor.website!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open web browser
                },
              ),
          ],
        ),
      ),
    );
  }

  void _reportContractor(ContractorModel contractor) {
    // TODO: Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report functionality not implemented yet')),
    );
  }
}
