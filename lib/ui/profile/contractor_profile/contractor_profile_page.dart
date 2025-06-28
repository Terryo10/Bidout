import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/profile_bloc/profile_bloc.dart';
import '../../../bloc/profile_bloc/profile_event.dart';
import '../../../bloc/profile_bloc/profile_state.dart';
import '../../../constants/app_theme_extension.dart';
import '../../../models/user_model.dart';
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
  final _portfolioDescriptionController = TextEditingController();

  // Skills and Certifications
  final _skillsController = TextEditingController();
  final _certificationsController = TextEditingController();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _availableForHire = true;
  List<String> _skills = [];
  List<String> _certifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _skillsController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  void _populateFields(UserModel user) {
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

    // Skills and Certifications
    _skills = user.skills ?? [];
    _certifications = user.certifications ?? [];
    _availableForHire = user.availableForHire;

    _skillsController.text = _skills.join(', ');
    _certificationsController.text = _certifications.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Professional'),
            Tab(text: 'Skills'),
          ],
          labelColor: context.colors.onPrimary,
          unselectedLabelColor: context.colors.onPrimary.withOpacity(0.7),
          indicatorColor: context.colors.onPrimary,
        ),
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

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPersonalTab(),
              _buildProfessionalTab(),
              _buildSkillsTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _personalFormKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            LoadingButton(
              text: 'Update Personal Info',
              onPressed: () {},
              isLoading: _isLoading,
            ),
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
          children: [
            CustomTextField(
              controller: _businessNameController,
              label: 'Business Name',
              hint: 'Enter your business name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _hourlyRateController,
              label: 'Hourly Rate',
              hint: 'Enter your hourly rate',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            LoadingButton(
              text: 'Update Professional Info',
              onPressed: () {},
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CustomTextField(
            controller: _skillsController,
            label: 'Skills',
            hint: 'Enter your skills (comma separated)',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _certificationsController,
            label: 'Certifications',
            hint: 'Enter your certifications (comma separated)',
            maxLines: 3,
          ),
          const SizedBox(height: 40),
          LoadingButton(
            text: 'Update Skills',
            onPressed: () {},
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
