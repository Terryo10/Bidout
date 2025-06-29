import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/bids_bloc/bids_bloc.dart';
import '../../../constants/app_theme_extension.dart';
import '../../../models/bids/bid_model.dart';
import '../../../models/projects/project_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';

@RoutePage()
class CreateBidPage extends StatefulWidget {
  final ProjectModel project;

  const CreateBidPage({
    super.key,
    required this.project,
  });

  @override
  State<CreateBidPage> createState() => _CreateBidPageState();
}

class _CreateBidPageState extends State<CreateBidPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timelineController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _proposedStartDate;
  DateTime? _proposedEndDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _timelineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Submit Bid',
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<BidsBloc, BidsState>(
        listener: (context, state) {
          if (state is BidCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Bid submitted successfully!'),
                backgroundColor: context.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is BidsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.error,
              ),
            );
          }

          setState(() {
            _isSubmitting = state is BidsLoading;
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectInfo(),
                const SizedBox(height: 24),
                _buildBidForm(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.project.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            if (widget.project.service?.name != null)
              Text(
                widget.project.service!.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: context.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Budget: R${NumberFormat('#,##0.00').format(widget.project.budget)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.project.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Bid',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Bid Amount
            CustomTextField(
              controller: _amountController,
              label: 'Bid Amount (R)',
              hint: 'Enter your bid amount',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your bid amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Timeline
            CustomTextField(
              controller: _timelineController,
              label: 'Timeline (Days)',
              hint: 'How many days to complete?',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the timeline';
                }
                final days = int.tryParse(value);
                if (days == null || days <= 0) {
                  return 'Please enter a valid number of days';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Proposed Start Date
            InkWell(
              onTap: _selectStartDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: context.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: context.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proposed Start Date',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.textSecondary,
                                    ),
                          ),
                          Text(
                            _proposedStartDate != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(_proposedStartDate!)
                                : 'Select start date',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Proposed End Date
            InkWell(
              onTap: _selectEndDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: context.borderLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: context.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proposed End Date',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.textSecondary,
                                    ),
                          ),
                          Text(
                            _proposedEndDate != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(_proposedEndDate!)
                                : 'Select end date',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            CustomTextField(
              controller: _descriptionController,
              label: 'Proposal Description',
              hint: 'Describe your approach and what you will deliver...',
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a description of your proposal';
                }
                if (value.trim().length < 50) {
                  return 'Please provide a more detailed description (minimum 50 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes (Optional)
            CustomTextField(
              controller: _notesController,
              label: 'Additional Notes (Optional)',
              hint: 'Any additional information...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBid,
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Submit Bid'),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _proposedStartDate = date;
        // If end date is before start date, clear it
        if (_proposedEndDate != null && _proposedEndDate!.isBefore(date)) {
          _proposedEndDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final startDate =
        _proposedStartDate ?? DateTime.now().add(const Duration(days: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: startDate.add(const Duration(days: 7)),
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _proposedEndDate = date;
      });
    }
  }

  void _submitBid() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bidRequest = BidRequestModel(
      projectId: widget.project.id,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.trim(),
      timeline: int.parse(_timelineController.text),
      proposedStartDate: _proposedStartDate,
      proposedEndDate: _proposedEndDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    context.read<BidsBloc>().add(BidCreateRequested(bidRequest: bidRequest));
  }
}
