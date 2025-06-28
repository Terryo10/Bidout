import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../bloc/profile_bloc/profile_bloc.dart';
import '../../../bloc/profile_bloc/profile_event.dart';
import '../../../bloc/profile_bloc/profile_state.dart';
import '../../../constants/app_theme_extension.dart';
import '../../../models/user_model.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/custom_text_field.dart';

@RoutePage()
class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _industryController = TextEditingController();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _companyNameController.dispose();
    _positionController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  void _populateFields(UserModel user) {
    _currentUser = user;
    _nameController.text = user.name;
    _phoneController.text = user.phone ?? '';
    _bioController.text = user.bio ?? '';
    _websiteController.text = user.website ?? '';
    _companyNameController.text = user.companyName ?? '';
    _positionController.text = user.position ?? '';
    _industryController.text = user.industry ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });

      // Update avatar immediately
      if (mounted) {
        context.read<ProfileBloc>().add(
              ProfileAvatarUpdateRequested(imagePath: pickedFile.path),
            );
      }
    }
  }

  void _updateProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final profileData = <String, dynamic>{};

      // Only include fields with actual values
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
      if (_companyNameController.text.trim().isNotEmpty) {
        profileData['company_name'] = _companyNameController.text.trim();
      }
      if (_positionController.text.trim().isNotEmpty) {
        profileData['position'] = _positionController.text.trim();
      }
      if (_industryController.text.trim().isNotEmpty) {
        profileData['industry'] = _industryController.text.trim();
      }

      context.read<ProfileBloc>().add(
            ClientProfileUpdateRequested(clientData: profileData),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
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
        builder: (context, state) {
          if (state is ProfileLoading && _currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              context.colors.primary.withOpacity(0.1),
                          backgroundImage: _currentUser?.avatar != null
                              ? NetworkImage(_currentUser!.avatar!)
                              : null,
                          child: _currentUser?.avatar == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: context.colors.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: context.colors.onPrimary,
                              ),
                              onPressed: _isLoading ? null : _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Personal Information Section
                  Text(
                    'Personal Information',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _bioController,
                    label: 'Bio',
                    hint: 'Tell us about yourself',
                    maxLines: 3,
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
                        final urlPattern =
                            r'^(https?|ftp)://[^\s/$.?#].[^\s]*$';
                        final regExp = RegExp(urlPattern);
                        if (!regExp.hasMatch(value)) {
                          return 'Please enter a valid URL';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Company Information Section
                  Text(
                    'Company Information',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _companyNameController,
                    label: 'Company Name',
                    hint: 'Enter your company name',
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _positionController,
                    label: 'Position/Title',
                    hint: 'Enter your position or title',
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _industryController,
                    label: 'Industry',
                    hint: 'Enter your industry',
                  ),
                  const SizedBox(height: 40),

                  // Update Button
                  LoadingButton(
                    text: 'Update Profile',
                    onPressed: _updateProfile,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
