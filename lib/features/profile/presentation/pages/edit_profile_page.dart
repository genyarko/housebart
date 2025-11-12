import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isLoading = false;
  XFile? _selectedImage;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _phoneController = TextEditingController(text: user.phone ?? '');
      _bioController = TextEditingController(text: user.bio ?? '');
      _avatarUrl = user.avatarUrl;
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _phoneController = TextEditingController();
      _bioController = TextEditingController();
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });

        // Upload the image
        final bytes = await image.readAsBytes();
        if (mounted) {
          context.read<ProfileBloc>().add(
                ProfileAvatarUploadEvent(
                  fileBytes: bytes,
                  fileName: image.name,
                ),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    context.read<ProfileBloc>().add(
          ProfileUpdateEvent(
            fullName: fullName,
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            context.pop();
          } else if (state is ProfileAvatarUploaded) {
            setState(() {
              _avatarUrl = state.avatarUrl;
              _isLoading = false;
            });
            // Refresh the AuthBloc to update the user's avatar URL
            context.read<AuthBloc>().add(AuthCheckRequested());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated successfully')),
            );
          } else if (state is ProfileError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileLoading) {
            setState(() => _isLoading = true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      _buildProfilePicture(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          radius: 20,
                          child: IconButton(
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt, size: 20),
                            color: Colors.white,
                            onPressed: _isLoading ? null : _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '+1 234 567 8900',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Bio
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline),
                    hintText: 'Tell us about yourself',
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    // Show selected image preview if available
    if (_selectedImage != null) {
      return FutureBuilder<Widget>(
        future: _buildImageFromFile(_selectedImage!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return const CircleAvatar(
            radius: 60,
            child: CircularProgressIndicator(),
          );
        },
      );
    }

    // Show avatar URL if available
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: CachedNetworkImageProvider(_avatarUrl!),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      );
    }

    // Show default placeholder
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const CircleAvatar(
            radius: 60,
            child: Icon(Icons.person, size: 60),
          );
        }
        final user = state.user;
        return CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  Future<Widget> _buildImageFromFile(XFile file) async {
    final bytes = await file.readAsBytes();
    return CircleAvatar(
      radius: 60,
      backgroundImage: MemoryImage(bytes),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
