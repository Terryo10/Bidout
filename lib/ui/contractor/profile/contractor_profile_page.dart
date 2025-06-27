// lib/ui/contractors/contractor_profile_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/contractor_bloc/contractor_bloc.dart';
import '../../../constants/app_theme_extension.dart';
import '../../../models/contractor/contractor_model.dart';
import '../../../models/contractor/portfolio_model.dart';
import '../../../models/contractor/contractor_review_model.dart';
import '../../../models/pagination/pagination_model.dart';
import '../../../repositories/contractor_repo/contractor_repo.dart';
import '../../widgets/contractor_review_card.dart';
import '../../widgets/portfolio_item_card.dart';

@RoutePage()
class ContractorProfilePage extends StatefulWidget {
  final int contractorId;

  const ContractorProfilePage({
    super.key,
    required this.contractorId,
  });

  @override
  State<ContractorProfilePage> createState() => _ContractorProfilePageState();
}

class _ContractorProfilePageState extends State<ContractorProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ContractorModel? _contractor;
  PaginationModel<PortfolioModel>? _portfolio;
  List<ContractorReviewModel> _reviews = [];

  String get _experienceText {
    if (_contractor == null) return 'N/A';
    final years = _contractor!.yearsExperience;
    if (years == null) return 'Not specified';
    return '$years years';
  }

  String get _rateText {
    if (_contractor == null) return 'N/A';
    final rate = _contractor!.hourlyRate;
    if (rate == null) return 'Rate not specified';
    return '\$${rate.toStringAsFixed(2)}/hr';
  }

  String get _formattedRating {
    if (_contractor == null) return 'N/A';
    return _contractor!.ratingDisplay;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContractorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadContractorData() {
    context.read<ContractorBloc>().add(
          ContractorSingleLoadRequested(
            contractorId: widget.contractorId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContractorBloc, ContractorState>(
      listener: (context, state) {
        if (state is ContractorSingleLoaded) {
          setState(() {
            _contractor = state.contractor;
            _portfolio = state.portfolio;
            _reviews = state.reviews ?? [];
          });
        }
      },
      builder: (context, state) {
        if (state is ContractorSingleLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ContractorError) {
          return _buildErrorView(errorMessage: state.message);
        }

        return _buildProfileView();
      },
    );
  }

  Widget _buildErrorView({String? errorMessage}) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor Profile'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Contractor not found',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ??
                  'An error occurred while loading the contractor profile',
              style: TextStyle(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.router.pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    if (_contractor == null) return const SizedBox.shrink();

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderSection(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  _shareContractor();
                },
              ),
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'contact',
                    child: Row(
                      children: [
                        Icon(Icons.email, color: context.textSecondary),
                        const SizedBox(width: 8),
                        Text('Contact'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report, color: context.error),
                        const SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Portfolio'),
                  Tab(text: 'Reviews'),
                ],
                labelColor: context.colors.primary,
                unselectedLabelColor: context.textSecondary,
                indicatorColor: context.colors.primary,
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutTab(),
          _buildPortfolioTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // Space for app bar

              // Avatar and Basic Info
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            context.colors.onPrimary.withOpacity(0.2),
                        backgroundImage: _contractor!.avatarUrl.isNotEmpty
                            ? NetworkImage(_contractor!.avatarUrl)
                            : null,
                        child: _contractor!.avatarUrl.isEmpty
                            ? Text(
                                _contractor!.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 32,
                                  color: context.colors.onPrimary,
                                ),
                              )
                            : null,
                      ),
                      if (_contractor!.emailVerifiedAt != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: context.colors.onPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified,
                              color: context.warning,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _contractor!.displayName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onPrimary,
                                ),
                              ),
                            ),
                            if (_contractor!.hasGoldenBadge)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.warning,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: context.colors.onPrimary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: context.colors.onPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        if (_contractor!.businessName != null &&
                            _contractor!.businessName != _contractor!.name)
                          Text(
                            _contractor!.businessName!,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.colors.onPrimary.withOpacity(0.9),
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Rating
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < _contractor!.rating.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: context.warning,
                                size: 18,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              _formattedRating,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    context.colors.onPrimary.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Experience', _experienceText),
                  _buildStatItem('Rate', _rateText),
                  _buildStatItem('Projects', '${_portfolio?.data.length ?? 0}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.colors.onPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.onPrimary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab() {
    return Material(
      color: context.colors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bio Section
            if (_contractor!.bio != null)
              _buildSection(
                'About',
                _contractor!.bio!,
              ),

            // Services Section
            if (_contractor != null && _contractor!.services.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                color: context.colors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _buildServiceChips(),
                    ),
                  ],
                ),
              ),
            ],

            // Certifications Section
            if (_contractor?.certifications?.isNotEmpty ?? false) ...[
              Text(
                'Certifications',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildCertificationChips(),
              ),
              const SizedBox(height: 24),
            ],

            // Skills Section
            if (_contractor?.skills?.isNotEmpty ?? false) ...[
              Text(
                'Skills',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildSkillChips(),
              ),
            ],

            // Contact Information
            const SizedBox(height: 24),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioTab() {
    if (_portfolio == null || _portfolio!.data.isEmpty) {
      return Material(
        color: context.colors.surface,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: context.textSecondary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No portfolio items yet',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This contractor hasn\'t added any portfolio items',
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: context.colors.surface,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _portfolio!.data.length,
        itemBuilder: (context, index) {
          final portfolioItem = _portfolio!.data[index];
          return PortfolioItemCard(
            portfolioItem: portfolioItem,
            onTap: () => _showPortfolioDetails(portfolioItem),
          );
        },
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_reviews.isEmpty) {
      return Material(
        color: context.colors.surface,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: context.textSecondary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No reviews yet',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This contractor hasn\'t received any reviews',
                  style: TextStyle(
                    color: context.textSecondary.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: context.colors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ContractorReviewCard(review: review),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderLight),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: context.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: context.textTheme.titleLarge?.copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderLight),
          ),
          child: Column(
            children: [
              _buildContactItem(
                Icons.email,
                'Email',
                _contractor!.email,
                () => _contactContractor('email'),
              ),
              if (_contractor!.phone != null)
                _buildContactItem(
                  Icons.phone,
                  'Phone',
                  _contractor!.phone!,
                  () => _contactContractor('phone'),
                ),
              if (_contractor!.website != null)
                _buildContactItem(
                  Icons.language,
                  'Website',
                  _contractor!.website!,
                  () => _contactContractor('website'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _contactContractor('email'),
                icon: const Icon(Icons.email),
                label: const Text('Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _hirContractor,
                icon: const Icon(Icons.work),
                label: const Text('Hire'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.secondary,
                  side: BorderSide(color: context.colors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: context.colors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              Icons.launch,
              color: context.colors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _shareContractor() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${_contractor!.displayName}\'s profile'),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'contact':
        _contactContractor('email');
        break;
      case 'report':
        _reportContractor();
        break;
    }
  }

  void _contactContractor(String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact ${_contractor!.displayName} via $method'),
      ),
    );
  }

  void _hirContractor() {
    // Navigate to create project with pre-selected contractor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hire ${_contractor!.displayName}'),
      ),
    );
  }

  void _reportContractor() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report ${_contractor!.displayName}'),
      ),
    );
  }

  void _showPortfolioDetails(PortfolioModel portfolioItem) {
    showDialog(
      context: context,
      builder: (context) =>
          PortfolioDetailsDialog(portfolioItem: portfolioItem),
    );
  }

  List<Widget> _buildServiceChips() {
    if (_contractor == null || _contractor!.services.isEmpty) {
      return [];
    }
    return _contractor!.services.map((service) {
      return Chip(
        label: Text(service.service?.name ?? 'Unknown Service'),
        backgroundColor: context.colors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: context.colors.primary,
        ),
      );
    }).toList();
  }

  List<Widget> _buildCertificationChips() {
    if (_contractor?.certifications?.isEmpty ?? true) {
      return [];
    }
    return _contractor!.certifications!.map((cert) {
      return Chip(
        label: Text(cert),
        backgroundColor: context.success.withOpacity(0.1),
        labelStyle: TextStyle(
          color: context.success,
        ),
      );
    }).toList();
  }

  List<Widget> _buildSkillChips() {
    if (_contractor?.skills?.isEmpty ?? true) {
      return [];
    }
    return _contractor!.skills!.map((skill) {
      return Chip(
        label: Text(skill),
        backgroundColor: context.info.withOpacity(0.1),
        labelStyle: TextStyle(
          color: context.info,
        ),
      );
    }).toList();
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(
            bottom: BorderSide(
              color: context.borderLight,
              width: 1,
            ),
          ),
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return true;
  }
}

class PortfolioDetailsDialog extends StatelessWidget {
  final PortfolioModel portfolioItem;

  const PortfolioDetailsDialog({
    super.key,
    required this.portfolioItem,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  portfolioItem.title,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (portfolioItem.primaryImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  portfolioItem.primaryImage!.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              portfolioItem.description ?? '',
              style: TextStyle(
                color: context.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            if (portfolioItem.completionDate != null) ...[
              Text(
                'Completed on: ${portfolioItem.formattedDate}',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (portfolioItem.projectValue != null) ...[
              Text(
                'Budget: ${portfolioItem.formattedValue}',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (portfolioItem.projectType != null) ...[
              Text(
                'Project Type: ${portfolioItem.projectType}',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
