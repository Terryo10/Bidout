import 'package:auto_route/auto_route.dart';
import 'package:bidout/constants/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../bloc/profile_bloc/profile_bloc.dart';
import '../../../bloc/profile_bloc/profile_event.dart';
import '../../../bloc/profile_bloc/profile_state.dart';
import '../../../bloc/services_bloc/services_bloc.dart';
import '../../../constants/app_theme_extension.dart';
import '../../../models/user_model.dart';
import '../../../models/services/service_model.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/custom_text_field.dart';

@RoutePage()
class EditContractorProfilePage extends StatefulWidget {
  const EditContractorProfilePage({super.key});

  @override
  State<EditContractorProfilePage> createState() =>
      _EditContractorProfilePageState();
}

class _EditContractorProfilePageState extends State<EditContractorProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _personalFormKey = GlobalKey<FormState>();
  final _professionalFormKey = GlobalKey<FormState>();
  final _servicesFormKey = GlobalKey<FormState>();

  // Personal Information Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();

  // Professional Information Controllers
  final _businessNameController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _experienceController = TextEditingController();

  // Services Controllers
  final _portfolioDescriptionController = TextEditingController();
  final _skillsInputController = TextEditingController();
  final _certificationsInputController = TextEditingController();

  UserModel? _currentUser;
  List<ServiceModel> _availableServices = [];
  bool _isLoading = false;
  bool _availableForHire = true;

  // Skills and Certifications Lists
  List<String> _skills = [];
  List<String> _certifications = [];

  // Provinces
  List<String> _selectedProvinces = [];
  List<String> _availableProvinces = [
    'Gauteng',
    'KwaZulu-Natal',
    'Western Cape',
    'Eastern Cape',
    'Limpopo',
    'Mpumalanga',
    'North West',
    'Free State',
    'Northern Cape',
  ];

  // Services
  List<Map<String, dynamic>> _contractorServices = [];
  Set<int> _expandedServices = {}; // Track which services are expanded
  bool _allServicesExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update bottom bar visibility
    });
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _businessNameController.dispose();
    _yearsExperienceController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    _portfolioDescriptionController.dispose();
    _skillsInputController.dispose();
    _certificationsInputController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  void _populateFields(UserModel user) {
    setState(() {
      _currentUser = user;

      // Personal Information
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _bioController.text = user.bio ?? '';
      _websiteController.text = user.website ?? '';

      // Professional Information
      _businessNameController.text = user.businessName ?? '';
      _yearsExperienceController.text = user.yearsExperience?.toString() ?? '';
      _hourlyRateController.text = user.hourlyRate?.toString() ?? '';
      _experienceController.text = user.experience ?? '';
      _portfolioDescriptionController.text = user.portfolioDescription ?? '';

      // Availability
      _availableForHire = user.availableForHire;

      // Skills and Certifications
      _skills = List<String>.from(user.skills ?? []);
      _certifications = List<String>.from(user.certifications ?? []);

      // Provinces - use the provinces from the backend (these are the selected ones)
      // Filter to only include active provinces that are also in our available list
      try {
        _selectedProvinces = user.provinces
            .where((province) => province.isActive)
            .map((province) => province.name)
            .where((name) => _availableProvinces.contains(name))
            .toList();
      } catch (e) {
        // Handle province processing errors gracefully
        _selectedProvinces = [];
      }

      // Contractor Services - use the real data from the backend
      try {
        _contractorServices = user.contractorServices.map((cs) {
          return <String, dynamic>{
            'id': cs.id,
            'service_id': cs.serviceId,
            'service_name': cs.serviceName,
            'experience_years': cs.experienceYears,
            'hourly_rate': cs.hourlyRate ?? 0.0,
            'is_primary_service': cs.isPrimaryService,
            'specialization_notes': cs.specializationNotes ?? '',
          };
        }).toList();
      } catch (e) {
        // Handle contractor services processing errors gracefully
        _contractorServices = [];
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null && mounted) {
      context.read<ProfileBloc>().add(
            ProfileAvatarUpdateRequested(imagePath: pickedFile.path),
          );
    }
  }

  void _removeAvatar() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Avatar'),
          content: const Text('Are you sure you want to remove your avatar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Update profile with null avatar
                context.read<ProfileBloc>().add(
                      ProfileUpdateRequested(profileData: {'avatar': null}),
                    );
              },
              child: Text(
                'Remove',
                style: TextStyle(color: context.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updatePersonalInfo() {
    if (_personalFormKey.currentState?.validate() ?? false) {
      final profileData = <String, dynamic>{};

      // Only include fields that have actual values (don't send null)
      if (_nameController.text.trim().isNotEmpty) {
        profileData['name'] = _nameController.text.trim();
      }
      if (_phoneController.text.trim().isNotEmpty) {
        profileData['phone'] = _phoneController.text.trim();
      }
      if (_bioController.text.trim().isNotEmpty) {
        profileData['bio'] = _bioController.text.trim();
      }
      if (_websiteController.text.trim().isNotEmpty) {
        profileData['website'] = _websiteController.text.trim();
      }

      context.read<ProfileBloc>().add(
            ProfileUpdateRequested(profileData: profileData),
          );
    }
  }

  void _updateProfessionalInfo() {
    if (_professionalFormKey.currentState?.validate() ?? false) {
      final contractorData = <String, dynamic>{};

      // Only include fields that have actual values
      if (_businessNameController.text.trim().isNotEmpty) {
        contractorData['business_name'] = _businessNameController.text.trim();
      }

      final yearsExp = int.tryParse(_yearsExperienceController.text.trim());
      if (yearsExp != null) {
        contractorData['years_experience'] = yearsExp;
      }

      final hourlyRate = double.tryParse(_hourlyRateController.text.trim());
      if (hourlyRate != null) {
        contractorData['hourly_rate'] = hourlyRate;
      }

      if (_experienceController.text.trim().isNotEmpty) {
        contractorData['experience'] = _experienceController.text.trim();
      }

      contractorData['available_for_hire'] = _availableForHire;

      if (_selectedProvinces.isNotEmpty) {
        contractorData['work_areas'] = _selectedProvinces;
      }

      context.read<ProfileBloc>().add(
            ContractorProfileUpdateRequested(contractorData: contractorData),
          );
    }
  }

  void _updateServices() {
    final servicesData = <String, dynamic>{};

    // Only include fields that have actual values
    if (_portfolioDescriptionController.text.trim().isNotEmpty) {
      servicesData['portfolio_description'] =
          _portfolioDescriptionController.text.trim();
    }

    if (_skills.isNotEmpty) {
      servicesData['skills'] = _skills;
    }

    if (_certifications.isNotEmpty) {
      servicesData['certifications'] = _certifications;
    }

    // Format contractor services properly for the API
    if (_contractorServices.isNotEmpty) {
      try {
        final validServices = _contractorServices
            .where((service) => service['service_id'] != null)
            .map((service) => {
                  'service_id': service['service_id'],
                  'experience_years': int.tryParse(
                          service['experience_years']?.toString() ?? '1') ??
                      1,
                  'hourly_rate': double.tryParse(
                          service['hourly_rate']?.toString() ?? '0') ??
                      0.0,
                  'specialization_notes':
                      service['specialization_notes']?.toString() ?? '',
                  'is_primary_service': service['is_primary_service'] == true,
                })
            .toList();

        if (validServices.isNotEmpty) {
          servicesData['services'] = validServices;
        }
      } catch (e) {
        // Handle contractor services formatting errors gracefully
      }
    }

    context.read<ProfileBloc>().add(
          ContractorProfileUpdateRequested(contractorData: servicesData),
        );
  }

  void _addSkill(String skill) {
    if (skill.trim().isNotEmpty && !_skills.contains(skill.trim())) {
      setState(() {
        _skills.add(skill.trim());
      });
      _skillsInputController.clear();
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _addCertification(String certification) {
    if (certification.trim().isNotEmpty &&
        !_certifications.contains(certification.trim())) {
      setState(() {
        _certifications.add(certification.trim());
      });
      _certificationsInputController.clear();
    }
  }

  void _removeCertification(String certification) {
    setState(() {
      _certifications.remove(certification);
    });
  }

  void _addService() {
    setState(() {
      final newServiceIndex = _contractorServices.length;
      _contractorServices.add({
        'id': null, // New service, no ID yet
        'service_id': null, // Will be selected by user
        'service_name': 'Select Service',
        'experience_years': 1,
        'hourly_rate': 0.0,
        'is_primary_service': false,
        'specialization_notes': '',
      });
      // Automatically expand the new service for editing
      _expandedServices.add(newServiceIndex);
    });
  }

  void _removeService(int index) {
    setState(() {
      _contractorServices.removeAt(index);
      // Update expanded services indices
      final newExpandedServices = <int>{};
      for (final expandedIndex in _expandedServices) {
        if (expandedIndex < index) {
          newExpandedServices.add(expandedIndex);
        } else if (expandedIndex > index) {
          newExpandedServices.add(expandedIndex - 1);
        }
        // Skip the removed index
      }
      _expandedServices = newExpandedServices;
    });
  }

  void _toggleServiceExpansion(int index) {
    setState(() {
      if (_expandedServices.contains(index)) {
        _expandedServices.remove(index);
      } else {
        _expandedServices.add(index);
      }
    });
  }

  void _collapseAllServices() {
    setState(() {
      _expandedServices.clear();
      _allServicesExpanded = false;
    });
  }

  void _expandAllServices() {
    setState(() {
      _expandedServices =
          Set.from(List.generate(_contractorServices.length, (index) => index));
      _allServicesExpanded = true;
    });
  }

  void _updateServiceField(int index, String field, dynamic value) {
    setState(() {
      _contractorServices[index][field] = value;

      // If service_id is being updated, also update service_name
      if (field == 'service_id' && _availableServices.isNotEmpty) {
        try {
          final selectedService =
              _availableServices.firstWhere((service) => service.id == value);
          _contractorServices[index]['service_name'] = selectedService.name;
        } catch (e) {
          _contractorServices[index]['service_name'] = 'Unknown Service';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Personal Information'),
            Tab(text: 'Professional Information'),
            Tab(text: 'Services Offered'),
            Tab(text: 'Subscription Info'),
          ],
          labelColor: context.colors.onPrimary,
          unselectedLabelColor: context.colors.onPrimary.withOpacity(0.7),
          indicatorColor: context.colors.onPrimary,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          // Profile bloc listener
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded) {
                _populateFields(state.user);
              } else if (state is ProfileUpdated) {
                _populateFields(state.user);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: context.success,
                  ),
                );
              } else if (state is ProfileAvatarUpdated) {
                _populateFields(state.user);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: context.success,
                  ),
                );
              } else if (state is ProfileError || state is ProfileUpdateError) {
                final message = state is ProfileError
                    ? state.message
                    : (state as ProfileUpdateError).message;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: context.error,
                  ),
                );
              } else if (state is ProfileValidationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errors.values.first),
                    backgroundColor: context.error,
                  ),
                );
              }

              setState(() {
                _isLoading = state is ProfileLoading ||
                    state is ProfileUpdating ||
                    state is ProfileAvatarUploading;
              });
            },
          ),
          // Services bloc listener
          BlocListener<ServicesBloc, ServicesState>(
            listener: (context, state) {
              if (state is ServicesLoaded) {
                setState(() {
                  _availableServices = state.services;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading && _currentUser == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalTab(),
                      _buildProfessionalTab(),
                      _buildServicesTab(),
                      _buildSubscriptionTab(),
                    ],
                  ),
                ),

                // Bottom Action Bar (like in Filament)
                if (_tabController.index !=
                    3) // Don't show save on subscription tab
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      border: Border(
                        top: BorderSide(color: context.borderLight),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: LoadingButton(
                            text: 'Save changes',
                            onPressed: _saveCurrentTab,
                            isLoading: _isLoading,
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _cancelChanges,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _saveCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _updatePersonalInfo();
        break;
      case 1:
        _updateProfessionalInfo();
        break;
      case 2:
        _updateServices();
        break;
    }
  }

  void _cancelChanges() {
    // Reload the profile to reset changes
    _loadProfile();
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            Text(
              'Basic Information',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Avatar Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Column
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avatar',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.borderLight),
                        ),
                        child: Stack(
                          children: [
                            // Avatar Image or Placeholder
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: _currentUser?.avatar != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        AppUrls.getAvatarUrl(
                                            _currentUser!.avatar!),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 64,
                                            color: context.textSecondary,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'No Avatar',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),

                            // Upload/Change Button
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.colors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _isLoading ? null : _pickImage,
                                  icon: Icon(
                                    _currentUser?.avatar != null
                                        ? Icons.edit
                                        : Icons.upload,
                                    color: context.colors.onPrimary,
                                    size: 20,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            // Remove Avatar Button (only if avatar exists)
                            if (_currentUser?.avatar != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: context.error,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed:
                                        _isLoading ? null : _removeAvatar,
                                    icon: Icon(
                                      Icons.delete,
                                      color: context.colors.onError,
                                      size: 18,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Name Column
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Name*',
                        hint: 'Enter your full name',
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Email and Phone Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller:
                        TextEditingController(text: _currentUser?.email ?? ''),
                    label: 'Email',
                    hint: 'Email address',
                    enabled: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Tell us about yourself',
              maxLines: 4,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: _websiteController,
              label: 'Website',
              hint: 'Enter your website URL',
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  // Only validate if not empty
                  final urlPattern = r'^(https?|ftp)://[^\s/$.?#].[^\s]*$';
                  final regExp = RegExp(urlPattern);
                  if (!regExp.hasMatch(value)) {
                    return 'Please enter a valid URL';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _professionalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Details Section
            Text(
              'Business Details',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _businessNameController,
              label: 'Business name',
              hint: 'Enter your business name',
            ),
            const SizedBox(height: 16),

            // Provinces Multi-Select
            Text(
              'Provinces You Serve',
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected provinces chips
                  if (_selectedProvinces.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedProvinces
                          .where((province) => _availableProvinces
                              .contains(province)) // Filter invalid ones
                          .map((province) => Chip(
                                label: Text(province),
                                onDeleted: () {
                                  setState(() {
                                    _selectedProvinces.remove(province);
                                  });
                                },
                                backgroundColor:
                                    context.warning.withOpacity(0.1),
                                labelStyle: TextStyle(color: context.warning),
                                deleteIconColor: context.warning,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Dropdown for available provinces
                  Builder(
                    builder: (context) {
                      // Calculate available provinces fresh each time
                      final availableForDropdown = _availableProvinces
                          .where((province) =>
                              !_selectedProvinces.contains(province))
                          .toList();

                      return DropdownButtonFormField<String>(
                        key: ValueKey(
                            'province_dropdown_${_selectedProvinces.join('_')}'),
                        value: null, // Always null
                        hint: Text(availableForDropdown.isEmpty
                            ? 'All provinces selected'
                            : 'Select a province to add'),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: availableForDropdown.isEmpty
                            ? []
                            : availableForDropdown
                                .map((province) => DropdownMenuItem<String>(
                                      value: province,
                                      child: Text(province),
                                    ))
                                .toList(),
                        onChanged: availableForDropdown.isEmpty
                            ? null
                            : (province) {
                                if (province != null &&
                                    _availableProvinces.contains(province) &&
                                    !_selectedProvinces.contains(province)) {
                                  setState(() {
                                    _selectedProvinces.add(province);
                                  });
                                }
                              },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Select the provinces where you provide services',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Years of Experience and Base Hourly Rate Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _yearsExperienceController,
                    label: 'Years of Experience',
                    hint: 'Enter years',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _hourlyRateController,
                    label: 'Base Hourly Rate',
                    hint: 'R 200,00',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Available for New Projects Toggle
            Row(
              children: [
                Switch(
                  value: _availableForHire,
                  onChanged: (value) {
                    setState(() {
                      _availableForHire = value;
                    });
                  },
                  activeColor: context.warning,
                ),
                const SizedBox(width: 12),
                Text(
                  'Available for New Projects',
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Experience & Skills Section
            Text(
              'Experience & Skills',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _experienceController,
              label: 'Professional Experience',
              hint: 'Describe your professional experience...',
              maxLines: 4,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _servicesFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Specialties Section
            Text(
              'Service Specialties',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _portfolioDescriptionController,
              label: 'Portfolio Overview',
              hint:
                  'Describe your expertise and what makes your work unique...',
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            // Service Categories Section
            Text(
              'Service Categories',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Contractor Services List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Contractor services',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _contractorServices.isEmpty
                                ? null
                                : _collapseAllServices,
                            child: const Text('Collapse all'),
                          ),
                          TextButton(
                            onPressed: _contractorServices.isEmpty
                                ? null
                                : _expandAllServices,
                            child: const Text('Expand all'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Service Items
                  ...List.generate(_contractorServices.length, (index) {
                    final service = _contractorServices[index];
                    return _buildServiceCard(service, index);
                  }),

                  const SizedBox(height: 16),

                  // Add Service Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _addService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.secondary,
                        foregroundColor: context.colors.onSecondary,
                      ),
                      child: const Text('Add Service'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Skills Section
            Text(
              'Skills',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _skillsInputController,
                    label: '',
                    hint: 'New tag',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addSkill(_skillsInputController.text),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            if (_skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills
                    .map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () => _removeSkill(skill),
                          backgroundColor:
                              context.colors.primary.withOpacity(0.1),
                          labelStyle: TextStyle(color: context.colors.primary),
                          deleteIconColor: context.colors.primary,
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Certifications Section
            Text(
              'Certifications',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _certificationsInputController,
                    label: '',
                    hint:
                        'Add certifications (e.g., Licensed Electrician, OSHA Certified)',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      _addCertification(_certificationsInputController.text),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            if (_certifications.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _certifications
                    .map((cert) => Chip(
                          label: Text(cert),
                          onDeleted: () => _removeCertification(cert),
                          backgroundColor: context.warning.withOpacity(0.1),
                          labelStyle: TextStyle(color: context.warning),
                          deleteIconColor: context.warning,
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Status',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Subscription Info Cards
          Row(
            children: [
              Expanded(
                child: _buildSubscriptionInfoCard(
                  'Current Plan',
                  _currentUser?.hasActiveSubscription == true
                      ? 'Premium'
                      : 'No Active Subscription',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSubscriptionInfoCard(
                  'Status',
                  _currentUser?.hasActiveSubscription == true
                      ? 'Active'
                      : 'Inactive',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSubscriptionInfoCard(
                  'Expires',
                  'N/A', // Would come from subscription data
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Manage Subscription Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to subscription management
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.credit_card),
              label: const Text('Manage Subscription'),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    final serviceName = service['service_name']?.toString() ?? 'Select Service';
    final isExpanded = _expandedServices.contains(index);
    final serviceId = service['service_id'];
    final experienceYears = service['experience_years']?.toString() ?? '1';
    final hourlyRate = service['hourly_rate']?.toString() ?? '0';
    final specializationNotes =
        service['specialization_notes']?.toString() ?? '';
    final isPrimaryService = service['is_primary_service'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderLight),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        serviceId != null ? context.success : context.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    serviceName,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isPrimaryService)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Primary',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeService(index),
                  icon: Icon(
                    Icons.delete,
                    color: context.error,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleServiceExpansion(index),
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
              ],
            ),
          ),

          // Expanded Content
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 16),

                  // Service Selection
                  BlocBuilder<ServicesBloc, ServicesState>(
                    builder: (context, servicesState) {
                      if (servicesState is ServicesLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (servicesState is ServicesError) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Error loading services: ${servicesState.message}',
                            style: TextStyle(color: context.error),
                          ),
                        );
                      }

                      if (servicesState is ServicesLoaded) {
                        return DropdownButtonFormField<int>(
                          value: serviceId,
                          hint: const Text('Select a service'),
                          decoration: const InputDecoration(
                            labelText: 'Service Type',
                            border: OutlineInputBorder(),
                          ),
                          items: servicesState.services
                              .where((service) => service.isActive)
                              .map((service) => DropdownMenuItem<int>(
                                    value: service.id,
                                    child: Text(service.name),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            _updateServiceField(index, 'service_id', value);
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Experience Years and Hourly Rate Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: experienceYears,
                          decoration: const InputDecoration(
                            labelText: 'Experience (Years)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final intValue = int.tryParse(value) ?? 1;
                            _updateServiceField(
                                index, 'experience_years', intValue);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: hourlyRate,
                          decoration: const InputDecoration(
                            labelText: 'Hourly Rate (R)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final doubleValue = double.tryParse(value) ?? 0.0;
                            _updateServiceField(
                                index, 'hourly_rate', doubleValue);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Specialization Notes
                  TextFormField(
                    initialValue: specializationNotes,
                    decoration: const InputDecoration(
                      labelText: 'Specialization Notes',
                      border: OutlineInputBorder(),
                      hintText: 'Describe your expertise in this service...',
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      _updateServiceField(index, 'specialization_notes', value);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Primary Service Toggle
                  Row(
                    children: [
                      Switch(
                        value: isPrimaryService,
                        onChanged: (value) {
                          // If setting this as primary, unset others
                          if (value) {
                            for (int i = 0;
                                i < _contractorServices.length;
                                i++) {
                              _updateServiceField(
                                  i, 'is_primary_service', i == index);
                            }
                          } else {
                            _updateServiceField(
                                index, 'is_primary_service', false);
                          }
                        },
                        activeColor: context.colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Primary Service',
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'This will be displayed as your main service',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.textSecondary,
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
          ],
        ],
      ),
    );
  }
}
