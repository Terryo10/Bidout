import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/contractor_bloc/contractor_bloc.dart';
import '../../constants/app_colors.dart';
import '../../models/contractor/contractor_model.dart';
import '../../models/contractor/portfolio_model.dart';
import '../widgets/portfolio_preview_card.dart';
import '../widgets/rating_display.dart';
import '../widgets/service_chip.dart';

@RoutePage()
class ContractorPreviewPage extends StatefulWidget {
  final int contractorId;

  const ContractorPreviewPage({
    super.key,
    @PathParam('id') required this.contractorId,
  });

  @override
  State<ContractorPreviewPage> createState() => _ContractorPreviewPageState();
}

class _ContractorPreviewPageState extends State<ContractorPreviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<ContractorBloc>().add(
          ContractorSingleLoadRequested(contractorId: widget.contractorId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ContractorBloc, ContractorState>(
        builder: (context, state) {
          if (state is ContractorSingleLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ContractorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ContractorBloc>().add(
                            ContractorSingleLoadRequested(
                              contractorId: widget.contractorId,
                            ),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ContractorSingleLoaded) {
            return _buildContractorPreview(state.contractor);
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildContractorPreview(ContractorModel contractor) {
    return CustomScrollView(
      slivers: [
        // App Bar with Contractor Info
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
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
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: contractor.avatar != null
                              ? NetworkImage(contractor.avatar!)
                              : null,
                          backgroundColor: AppColors.white.withOpacity(0.2),
                          child: contractor.avatar == null
                              ? Text(
                                  contractor.name.isNotEmpty
                                      ? contractor.name[0].toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        if (contractor.hasGoldenBadge)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: AppColors.warning,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (contractor.businessName != null)
                      Text(
                        contractor.businessName!,
                        style: const TextStyle(
                          color: AppColors.white,
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

        // Contractor Details
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Rating and Reviews
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rating & Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RatingDisplay(
                        rating: contractor.rating,
                        totalReviews: contractor.totalReviews,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Services
              if (contractor.services.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Services Offered',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: contractor.services
                              .map((service) => ServiceChip(
                                    label: service.service?.name ?? 'Unknown',
                                    isPrimary: service.isPrimaryService,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Experience and Rate
              if (contractor.yearsExperience != null ||
                  contractor.hourlyRate != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Experience & Rate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (contractor.yearsExperience != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Experience',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '${contractor.yearsExperience} years',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (contractor.hourlyRate != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hourly Rate',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '\$${contractor.hourlyRate!.toStringAsFixed(2)}/hr',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Portfolio Preview
              if (contractor.featuredPortfolios.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Featured Portfolio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: contractor.featuredPortfolios.length,
                            itemBuilder: (context, index) {
                              final portfolio =
                                  contractor.featuredPortfolios[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: PortfolioPreviewCard(
                                  portfolio: portfolio,
                                  onTap: () => _viewPortfolio(portfolio),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

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
    );
  }

  void _shareContractor(ContractorModel contractor) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _contactContractor(ContractorModel contractor) {
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
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: contractor.email,
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
            if (contractor.phone != null)
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.success),
                title: const Text('Call'),
                subtitle: Text(contractor.phone!),
                onTap: () async {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: contractor.phone,
                  );
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
            if (contractor.website != null)
              ListTile(
                leading: const Icon(Icons.web, color: AppColors.info),
                title: const Text('Visit Website'),
                subtitle: Text(contractor.website!),
                onTap: () async {
                  final Uri websiteUri = Uri.parse(contractor.website!);
                  if (await canLaunchUrl(websiteUri)) {
                    await launchUrl(websiteUri);
                  }
                  if (mounted) Navigator.pop(context);
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
      const SnackBar(content: Text('Report functionality coming soon')),
    );
  }

  void _viewPortfolio(PortfolioModel portfolio) {
    // TODO: Implement portfolio view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Portfolio view coming soon')),
    );
  }
}
