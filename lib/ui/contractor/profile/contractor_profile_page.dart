// lib/ui/contractors/contractor_profile_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/app_colors.dart';
import '../../../models/contractor/contractor_model.dart';
import '../../../models/contractor/portfolio_item_model.dart';
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
  List<PortfolioItemModel> _portfolio = [];
  List<ContractorReviewModel> _reviews = [];
  
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

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

  void _loadContractorData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final contractorRepository = context.read<ContractorRepository>();
      
      // Load contractor details
      final contractor = await contractorRepository.getContractor(widget.contractorId);
      
      if (contractor == null) {
        throw Exception('Contractor not found');
      }

      // Load portfolio and reviews in parallel
      final portfolioFuture = contractorRepository.getContractorPortfolio(widget.contractorId);
      final reviewsFuture = contractorRepository.getContractorReviews(widget.contractorId);
      
      final results = await Future.wait([portfolioFuture, reviewsFuture]);
      
      setState(() {
        _contractor = contractor;
        _portfolio = results[0] as List<PortfolioItemModel>;
        _reviews = results[1] as List<ContractorReviewModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorView()
              : _buildProfileView(),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Contractor not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: AppColors.textSecondary,
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
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
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
                  const PopupMenuItem(
                    value: 'contact',
                    child: Row(
                      children: [
                        Icon(Icons.email),
                        SizedBox(width: 8),
                        Text('Contact'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report),
                        SizedBox(width: 8),
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
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withOpacity(0.2),
                      image: _contractor!.avatar != null
                          ? DecorationImage(
                              image: NetworkImage(_contractor!.avatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _contractor!.avatar == null
                        ? const Icon(
                            Icons.person,
                            color: AppColors.white,
                            size: 40,
                          )
                        : null,
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
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
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
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: AppColors.white,
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
                              color: AppColors.white.withOpacity(0.9),
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
                                color: AppColors.warning,
                                size: 18,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              _contractor!.formattedRating,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white.withOpacity(0.9),
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
                  _buildStatItem('Experience', _contractor!.experienceText),
                  _buildStatItem('Rate', _contractor!.rateText),
                  _buildStatItem('Projects', '${_portfolio.length}'),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
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
          if (_contractor!.services.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Services Offered',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._contractor!.services.map((service) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.build,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.serviceName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${service.experienceYears} years experience',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (service.hourlyRate != null)
                          Text(
                            '\$${service.hourlyRate!.toStringAsFixed(0)}/hr',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          
          // Skills Section
          if (_contractor!.skills.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _contractor!.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          
          // Contact Information
          const SizedBox(height: 24),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab() {
    if (_portfolio.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No portfolio items yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This contractor hasn\'t added any portfolio items',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _portfolio.length,
      itemBuilder: (context, index) {
        final portfolioItem = _portfolio[index];
        return PortfolioItemCard(
          portfolioItem: portfolioItem,
          onTap: () {
            _showPortfolioDetails(portfolioItem);
          },
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    if (_reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This contractor hasn\'t received any reviews',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ContractorReviewCard(review: review),
        );
      },
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
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
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
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
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
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
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(
              Icons.launch,
              color: AppColors.primary,
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

  void _showPortfolioDetails(PortfolioItemModel portfolioItem) {
    showDialog(
      context: context,
      builder: (context) => PortfolioDetailsDialog(portfolioItem: portfolioItem),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class PortfolioDetailsDialog extends StatelessWidget {
  final PortfolioItemModel portfolioItem;

  const PortfolioDetailsDialog({
    super.key,
    required this.portfolioItem,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            
            // Portfolio details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    portfolioItem.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (portfolioItem.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        portfolioItem.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}