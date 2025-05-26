// lib/ui/projects/create_project_page.dart
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/projects_bloc/project_bloc.dart';
import '../../constants/app_colors.dart';
import '../../models/services/service_model.dart' as service;
import '../../repositories/projects_repo/projects_repository.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';

@RoutePage()
class CreateProjectPage extends StatefulWidget {
  final int? preSelectedServiceId;

  const CreateProjectPage({
    super.key,
    this.preSelectedServiceId,
  });

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _additionalRequirementsController = TextEditingController();
  final _budgetController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  String _selectedFrequency = 'One-time';
  String _selectedKeyFactor = 'quality';
  DateTime? _startDate;
  DateTime? _endDate;
  service.ServiceModel? _selectedService;
  bool _isDrafted = false;
  List<String> _imagePaths = [];
  List<service.ServiceModel> _services = [];
  bool _isLoadingServices = true;

  final List<String> _frequencies = [
    'One-time',
    'Daily',
    'Weekly',
    'Bi-weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
  ];

  final List<String> _keyFactors = [
    'quality',
    'timeline',
    'cost',
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _additionalRequirementsController.dispose();
    _budgetController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final projectRepository = context.read<ProjectRepository>();
      final services = await projectRepository.getServices();
      setState(() {
        _services = services;
        _isLoadingServices = false;

        // Pre-select service if provided
        if (widget.preSelectedServiceId != null) {
          _selectedService = services.firstWhere(
            (service) => service.id == widget.preSelectedServiceId,
            orElse: () => services.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingServices = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load services: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(images.map((image) => image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleSubmit({bool isDraft = false}) {
    if (_formKey.currentState!.validate()) {
      if (_selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a service'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select start and end dates'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<ProjectBloc>().add(
            ProjectCreateRequested(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              additionalRequirements:
                  _additionalRequirementsController.text.trim().isNotEmpty
                      ? _additionalRequirementsController.text.trim()
                      : null,
              budget: double.parse(_budgetController.text),
              frequency: _selectedFrequency,
              keyFactor: _selectedKeyFactor,
              startDate: _startDate!,
              endDate: _endDate!,
              street: _streetController.text.trim().isNotEmpty
                  ? _streetController.text.trim()
                  : null,
              city: _cityController.text.trim().isNotEmpty
                  ? _cityController.text.trim()
                  : null,
              state: _stateController.text.trim().isNotEmpty
                  ? _stateController.text.trim()
                  : null,
              zipCode: _zipCodeController.text.trim().isNotEmpty
                  ? _zipCodeController.text.trim()
                  : null,
              serviceId: _selectedService!.id,
              imagePaths: _imagePaths,
              isDrafted: isDraft,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isDrafted
                      ? 'Project saved as draft successfully'
                      : 'Project created successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            context.router.pop();
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Details Section
                _buildSectionHeader('Project Details'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _titleController,
                  label: 'Project Title',
                  hint: 'Enter project title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Service Selection
                if (_isLoadingServices)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<service.ServiceModel>(
                        value: _selectedService,
                        decoration: InputDecoration(
                          hintText: 'Select a service',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                        items: _services.map((serviceItem) {
                          return DropdownMenuItem<service.ServiceModel>(
                            value: serviceItem,
                            child: Text(serviceItem.name),
                          );
                        }).toList(),
                        onChanged: (service.ServiceModel? value) {
                          setState(() {
                            _selectedService = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a service';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe your project in detail',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _additionalRequirementsController,
                  label: 'Additional Requirements (Optional)',
                  hint: 'Any additional requirements or specifications',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Budget and Timeline Section
                _buildSectionHeader('Budget & Timeline'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _budgetController,
                  label: 'Budget (\$)',
                  hint: 'Enter your budget',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Frequency Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      items: _frequencies.map((frequency) {
                        return DropdownMenuItem<String>(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedFrequency = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Key Factor Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Most Important Factor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedKeyFactor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      items: _keyFactors.map((factor) {
                        return DropdownMenuItem<String>(
                          value: factor,
                          child: Text(factor.capitalize()),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedKeyFactor = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Selection
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppColors.borderLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _startDate != null
                                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                        : 'Select date',
                                    style: TextStyle(
                                      color: _startDate != null
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppColors.borderLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _endDate != null
                                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                        : 'Select date',
                                    style: TextStyle(
                                      color: _endDate != null
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Location Section
                _buildSectionHeader('Location'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _streetController,
                  label: 'Street Address (Optional)',
                  hint: 'Enter street address',
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _cityController,
                        label: 'City (Optional)',
                        hint: 'Enter city',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _stateController,
                        label: 'State (Optional)',
                        hint: 'Enter state',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _zipCodeController,
                  label: 'Zip Code (Optional)',
                  hint: 'Enter zip code',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Images Section
                _buildSectionHeader('Project Images'),
                const SizedBox(height: 16),

                // Add Images Button
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grey100,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 16),

                // Display Selected Images
                if (_imagePaths.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagePaths.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imagePaths[index]),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<ProjectBloc, ProjectState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is ProjectLoading
                                ? null
                                : () => _handleSubmit(isDraft: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.grey400,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: state is ProjectLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          AppColors.white),
                                    ),
                                  )
                                : const Text('Save as Draft'),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: BlocBuilder<ProjectBloc, ProjectState>(
                        builder: (context, state) {
                          return LoadingButton(
                            onPressed: () => _handleSubmit(isDraft: false),
                            isLoading: state is ProjectLoading,
                            text: 'Create Project',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
