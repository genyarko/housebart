import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';

/// Page for adding a new property
class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaSqftController = TextEditingController();

  String _selectedPropertyType = 'house';
  final List<String> _selectedAmenities = [];
  final List<String> _houseRules = [];
  final List<String> _selectedImagePaths = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  String? _createdPropertyId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _maxGuestsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaSqftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
      ),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state is PropertyLoading) {
            setState(() => _isLoading = true);
          } else if (state is PropertyCreated) {
            // Property created, now upload images if any
            _createdPropertyId = state.property.id;
            if (_selectedImagePaths.isNotEmpty) {
              context.read<PropertyBloc>().add(
                    PropertyImagesUploadRequested(
                      propertyId: state.property.id,
                      imagePaths: _selectedImagePaths,
                    ),
                  );
            } else {
              // No images to upload, just show success and close
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Property created successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.pop(true);
            }
          } else if (state is PropertyImagesUploaded) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Property created with ${state.imageUrls.length} image(s)!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop(true);
          } else if (state is PropertyError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Basic Information Section
                _buildSectionTitle('Basic Information'),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _titleController,
                  label: 'Property Title',
                  hint: 'e.g., Beautiful Beach House in Miami',
                  validator: Validators.validatePropertyTitle,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your property...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: Validators.validatePropertyDescription,
                ),
                const SizedBox(height: 16),

                // Property Type
                DropdownButtonFormField<String>(
                  value: _selectedPropertyType,
                  decoration: const InputDecoration(
                    labelText: 'Property Type',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.propertyTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPropertyType = value!);
                  },
                ),
                const SizedBox(height: 24),

                // Location Section
                _buildSectionTitle('Location'),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _addressController,
                  label: 'Street Address',
                  hint: '123 Main Street',
                  validator: (value) => Validators.validateRequired(value, 'Street Address'),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AuthTextField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'New York',
                        validator: Validators.validateCity,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthTextField(
                        controller: _stateController,
                        label: 'State/Province',
                        hint: 'NY',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AuthTextField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'United States',
                        validator: Validators.validateCountry,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthTextField(
                        controller: _postalCodeController,
                        label: 'Postal Code',
                        hint: '10001',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Coordinates
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 53.079231',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          // Allow empty values
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          final lat = double.tryParse(value);
                          if (lat == null || lat < -90 || lat > 90) {
                            return 'Invalid latitude (-90 to 90)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 8.906081',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          // Allow empty values
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          final lng = double.tryParse(value);
                          if (lng == null || lng < -180 || lng > 180) {
                            return 'Invalid longitude (-180 to 180)';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: Coordinates are optional and can be added later from Google Maps',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),

                // Property Details Section
                _buildSectionTitle('Property Details'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _maxGuestsController,
                        decoration: const InputDecoration(
                          labelText: 'Max Guests',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final guests = int.tryParse(value);
                          if (guests == null || guests < 1) {
                            return 'Min 1 guest';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _bedroomsController,
                        decoration: const InputDecoration(
                          labelText: 'Bedrooms',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final bedrooms = int.tryParse(value);
                          if (bedrooms == null || bedrooms < 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomsController,
                        decoration: const InputDecoration(
                          labelText: 'Bathrooms',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final bathrooms = int.tryParse(value);
                          if (bathrooms == null || bathrooms < 1) {
                            return 'Min 1';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _areaSqftController,
                        decoration: const InputDecoration(
                          labelText: 'Area (sq ft)',
                          border: OutlineInputBorder(),
                          hintText: 'Optional',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Amenities Section
                _buildSectionTitle('Amenities'),
                const SizedBox(height: 16),
                _buildAmenitiesSelector(),
                const SizedBox(height: 24),

                // Images Section
                _buildSectionTitle('Property Images'),
                const SizedBox(height: 16),
                _buildImageSelector(),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Property'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildAmenitiesSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.commonAmenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity);
        return FilterChip(
          label: Text(amenity),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected images display
        if (_selectedImagePaths.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImagePaths[index]),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImagePaths.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
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
        const SizedBox(height: 16),
        // Image selection buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick from Gallery'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedImagePaths.isEmpty
              ? 'No images selected (optional)'
              : '${_selectedImagePaths.length} image(s) selected',
          style: TextStyle(
            fontSize: 12,
            color: _selectedImagePaths.isEmpty
                ? AppColors.textSecondary
                : AppColors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImagePaths.addAll(images.map((image) => image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick images: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        setState(() {
          _selectedImagePaths.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedAmenities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one amenity'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Parse optional coordinates
      final latText = _latitudeController.text.trim();
      final lngText = _longitudeController.text.trim();
      final latitude = latText.isNotEmpty ? double.tryParse(latText) : null;
      final longitude = lngText.isNotEmpty ? double.tryParse(lngText) : null;

      context.read<PropertyBloc>().add(
            PropertyCreateRequested(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              address: _addressController.text.trim(),
              city: _cityController.text.trim(),
              stateProvince: _stateController.text.trim().isNotEmpty
                  ? _stateController.text.trim()
                  : null,
              country: _countryController.text.trim(),
              postalCode: _postalCodeController.text.trim().isNotEmpty
                  ? _postalCodeController.text.trim()
                  : null,
              latitude: latitude,
              longitude: longitude,
              propertyType: _selectedPropertyType,
              maxGuests: int.parse(_maxGuestsController.text.trim()),
              bedrooms: int.parse(_bedroomsController.text.trim()),
              bathrooms: int.parse(_bathroomsController.text.trim()),
              areaSqft: _areaSqftController.text.trim().isNotEmpty
                  ? int.parse(_areaSqftController.text.trim())
                  : null,
              amenities: _selectedAmenities,
              houseRules: _houseRules.isNotEmpty ? _houseRules : null,
            ),
          );
    }
  }
}
