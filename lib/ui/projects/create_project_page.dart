// lib/ui/projects/create_project_page.dart
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/projects_bloc/project_bloc.dart';
import '../../bloc/services_bloc/services_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/services/service_model.dart' as service;
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
          SnackBar(
            content: const Text('Please select a service'),
            backgroundColor: context.error,
          ),
        );
        return;
      }

      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select start and end dates'),
            backgroundColor: context.error,
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
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
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
                backgroundColor: context.success,
              ),
            );
            context.router.pop();
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.error,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<ServicesBloc, ServicesState>(
                      builder: (context, state) {
                        if (state is ServicesLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state is ServicesError) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.message,
                                style: TextStyle(color: context.error),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  context
                                      .read<ServicesBloc>()
                                      .add(ServicesLoadRequested());
                                },
                                icon: Icon(Icons.refresh,
                                    color: context.colors.primary),
                                label: Text(
                                  'Retry',
                                  style:
                                      TextStyle(color: context.colors.primary),
                                ),
                              ),
                            ],
                          );
                        }

                        if (state is ServicesLoaded) {
                          // Pre-select service if provided and not already selected
                          if (_selectedService == null &&
                              widget.preSelectedServiceId != null) {
                            _selectedService = state.services.firstWhere(
                              (service) =>
                                  service.id == widget.preSelectedServiceId,
                              orElse: () => state.services.first,
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<service.ServiceModel>(
                                value: _selectedService,
                                decoration: InputDecoration(
                                  hintText: 'Select a service',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: context.borderLight),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: context.borderLight),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: context.colors.primary),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.refresh,
                                        color: context.textSecondary),
                                    onPressed: () {
                                      context
                                          .read<ServicesBloc>()
                                          .add(ServicesLoadRequested());
                                    },
                                  ),
                                ),
                                items: state.services.map((serviceItem) {
                                  return DropdownMenuItem<service.ServiceModel>(
                                    value: serviceItem,
                                    child: Text(
                                      serviceItem.name,
                                      style:
                                          TextStyle(color: context.textPrimary),
                                    ),
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
                              if (state.services.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      context
                                          .read<ServicesBloc>()
                                          .add(ServicesLoadRequested());
                                    },
                                    icon: Icon(Icons.refresh,
                                        color: context.colors.primary),
                                    label: Text(
                                      'Refresh Services',
                                      style: TextStyle(
                                          color: context.colors.primary),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }

                        return Container(); // Initial state
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
                    Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: context.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: context.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: context.colors.primary),
                        ),
                      ),
                      items: _frequencies.map((frequency) {
                        return DropdownMenuItem<String>(
                          value: frequency,
                          child: Text(
                            frequency,
                            style: TextStyle(color: context.textPrimary),
                          ),
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
                    Text(
                      'Most Important Factor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedKeyFactor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: context.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: context.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: context.colors.primary),
                        ),
                      ),
                      items: _keyFactors.map((factor) {
                        return DropdownMenuItem<String>(
                          value: factor,
                          child: Text(
                            factor.capitalize(),
                            style: TextStyle(color: context.textPrimary),
                          ),
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
                          Text(
                            'Start Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.textPrimary,
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
                                  Text(
                                    _startDate != null
                                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                        : 'Select date',
                                    style: TextStyle(
                                      color: _startDate != null
                                          ? context.textPrimary
                                          : context.textSecondary,
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
                          Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.textPrimary,
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
                                  Text(
                                    _endDate != null
                                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                        : 'Select date',
                                    style: TextStyle(
                                      color: _endDate != null
                                          ? context.textPrimary
                                          : context.textSecondary,
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
                    backgroundColor: context.colors.surfaceContainer,
                    foregroundColor: context.textPrimary,
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
                                    decoration: BoxDecoration(
                                      color: context.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: context.colors.onPrimary,
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

                // Draft Switch
                Row(
                  children: [
                    Text(
                      'Save as Draft',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CupertinoSwitch(
                      value: _isDrafted,
                      onChanged: (bool value) {
                        setState(() {
                          _isDrafted = value;
                        });
                      },
                      activeColor: context.colors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, state) {
                    return LoadingButton(
                      onPressed: () => _handleSubmit(isDraft: _isDrafted),
                      isLoading: state is ProjectLoading,
                      text: 'Create Project',
                    );
                  },
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
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.textPrimary,
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
