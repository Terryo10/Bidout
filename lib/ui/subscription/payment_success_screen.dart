import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../constants/app_theme_extension.dart';

@RoutePage()
class PaymentSuccessScreen extends StatefulWidget {
  final String type; // 'subscription' or 'bids'
  final String packageName;
  final double amount;
  final int? bidCount;
  final Map<String, dynamic>? details;

  const PaymentSuccessScreen({
    super.key,
    required this.type,
    required this.packageName,
    required this.amount,
    this.bidCount,
    this.details,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });

    // Auto-navigate to dashboard after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _navigateToDashboard();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    if (mounted) {
      // Navigate to appropriate dashboard based on user type
      context.router.replace(const ContractorDashboardRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: _navigateToDashboard,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Animation
                    SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Fallback success icon if Lottie fails
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              size: 80,
                              color: Colors.green.shade600,
                            ),
                          ),
                          // Try to load Lottie animation
                          // Note: You'll need to add lottie package and animation file
                          // For now, we'll use the icon above
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Success Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Payment Successful!',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Purchase Details
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Package',
                              widget.packageName,
                              Icons.shopping_bag,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Amount Paid',
                              'R ${widget.amount.toStringAsFixed(2)}',
                              Icons.payment,
                            ),
                            if (widget.type == 'bids' &&
                                widget.bidCount != null) ...[
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                'Bids Purchased',
                                '${widget.bidCount} bids',
                                Icons.how_to_vote,
                              ),
                            ],
                            if (widget.type == 'subscription') ...[
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                'Subscription',
                                'Now Active',
                                Icons.star,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Success Message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.type == 'subscription'
                            ? 'Your subscription is now active! You can start bidding on projects immediately.'
                            : 'Your bids have been added to your account! You can now submit more proposals.',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _navigateToDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go to Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Navigate to projects/bidding screen
                        _navigateToDashboard();
                      },
                      child: Text(
                        widget.type == 'subscription'
                            ? 'Start Bidding on Projects'
                            : 'Browse Available Projects',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Redirecting to dashboard in 5 seconds...',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.green.shade600,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
