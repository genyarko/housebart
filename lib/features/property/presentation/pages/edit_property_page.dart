import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';

/// Page for editing an existing property
class EditPropertyPage extends StatefulWidget {
  final Property property;

  const EditPropertyPage({
    super.key,
    required this.property,
  });

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _maxGuestsController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _areaSqftController;

  late String _selectedPropertyType;
  late String _selectedPropertyCategory;
  late String _selectedListingType;
  late final TextEditingController _karmaPriceController;
  late List<String> _selectedAmenities;
  late List<String> _houseRules;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current property values
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController = TextEditingController(text: widget.property.description);
    _addressController = TextEditingController(text: widget.property.location.address);
    _cityController = TextEditingController(text: widget.property.location.city);
    _stateController = TextEditingController(text: widget.property.location.stateProvince ?? '');
    _countryController = TextEditingController(text: widget.property.location.country);
    _postalCodeController = TextEditingController(text: widget.property.location.postalCode ?? '');
    _latitudeController = TextEditingController(
      text: widget.property.location.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.property.location.longitude?.toString() ?? '',
    );
    _maxGuestsController = TextEditingController(text: widget.property.details.maxGuests.toString());
    _bedroomsController = TextEditingController(text: widget.property.details.bedrooms.toString());
    _bathroomsController = TextEditingController(text: widget.property.details.bathrooms.toString());
    _areaSqftController = TextEditingController(
      text: widget.property.details.areaSqft?.toString() ?? '',
    );

    _selectedPropertyType = widget.property.details.propertyType;
    _selectedPropertyCategory = _propertyCategoryToString(widget.property.propertyCategory);
    _selectedListingType = _listingTypeToString(widget.property.listingType);
    _karmaPriceController = TextEditingController(
      text: widget.property.karmaPrice?.toString() ?? '',
    );
    _selectedAmenities = List.from(widget.property.amenities);
    _houseRules = List.from(widget.property.houseRules);
  }

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
    _karmaPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
      ),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state is PropertyLoading) {
            setState(() => _isLoading = true);
          } else if (state is PropertyUpdated) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Property updated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop(true); // Return true to indicate success
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
                const SizedBox(height: 16),

                // Property Category
                DropdownButtonFormField<String>(
                  value: _selectedPropertyCategory,
                  decoration: const InputDecoration(
                    labelText: 'Property Category',
                    border: OutlineInputBorder(),
                    helperText: 'What type of property are you listing?',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'vacation_home',
                      child: Text('Vacation Home'),
                    ),
                    DropdownMenuItem(
                      value: 'spare_property',
                      child: Text('Spare Home/Property'),
                    ),
                    DropdownMenuItem(
                      value: 'primary_home',
                      child: Text('Primary Home'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPropertyCategory = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Listing Type Section
                _buildSectionTitle('Listing Type'),
                const SizedBox(height: 8),
                Text(
                  'Choose how guests can book your property',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Listing Type Selection
                DropdownButtonFormField<String>(
                  value: _selectedListingType,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'barter',
                      child: Row(
                        children: [
                          Icon(Icons.sync, size: 20),
                          SizedBox(width: 8),
                          Text('Barter (Exchange Properties)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'karma_points',
                      child: Row(
                        children: [
                          Icon(Icons.bolt, size: 20, color: AppColors.accent),
                          SizedBox(width: 8),
                          Text('Karma Points'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedListingType = value!;
                      if (value == 'barter') {
                        _karmaPriceController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Karma Price (only shown if karma_points selected)
                if (_selectedListingType == 'karma_points')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _karmaPriceController,
                        decoration: InputDecoration(
                          labelText: 'Karma Price (Per Day)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.bolt, color: AppColors.accent),
                          suffixText: 'Karma Points/Day',
                          helperText: 'How many karma points per day (24 hours)?',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (_selectedListingType == 'karma_points') {
                            if (value == null || value.isEmpty) {
                              return 'Karma price is required';
                            }
                            final price = int.tryParse(value);
                            if (price == null || price < 1) {
                              return 'Price must be at least 1 karma point';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Karma points allow users to book your property without offering their own. Charges are calculated per day (24 hours). Example: 50 karma/day × 3 days = 150 karma total.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
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
                          if (value == null || value.isEmpty) return null;
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
                          if (value == null || value.isEmpty) return null;
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final guests = int.tryParse(value);
                          if (guests == null || guests < 1) return 'Min 1 guest';
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final bedrooms = int.tryParse(value);
                          if (bedrooms == null || bedrooms < 0) return 'Invalid';
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final bathrooms = int.tryParse(value);
                          if (bathrooms == null || bathrooms < 1) return 'Min 1';
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Update Property'),
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

      // Parse karma price if listing type is karma_points
      int? karmaPrice;
      if (_selectedListingType == 'karma_points') {
        final karmaPriceText = _karmaPriceController.text.trim();
        if (karmaPriceText.isNotEmpty) {
          karmaPrice = int.tryParse(karmaPriceText);
        }
      }

      // Build updates map
      final updates = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state_province': _stateController.text.trim().isNotEmpty
            ? _stateController.text.trim()
            : null,
        'country': _countryController.text.trim(),
        'postal_code': _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        'latitude': latitude,
        'longitude': longitude,
        'property_type': _selectedPropertyType,
        'property_category': _selectedPropertyCategory,
        'max_guests': int.parse(_maxGuestsController.text.trim()),
        'bedrooms': int.parse(_bedroomsController.text.trim()),
        'bathrooms': int.parse(_bathroomsController.text.trim()),
        'area_sqft': _areaSqftController.text.trim().isNotEmpty
            ? int.parse(_areaSqftController.text.trim())
            : null,
        'amenities': _selectedAmenities,
        'house_rules': _houseRules.isNotEmpty ? _houseRules : null,
        'listing_type': _selectedListingType,
        'karma_price': karmaPrice,
      };

      context.read<PropertyBloc>().add(
            PropertyUpdateRequested(
              propertyId: widget.property.id,
              updates: updates,
            ),
          );
    }
  }

  /// Convert PropertyCategory enum to string
  String _propertyCategoryToString(PropertyCategory category) {
    switch (category) {
      case PropertyCategory.vacationHome:
        return 'vacation_home';
      case PropertyCategory.spareProperty:
        return 'spare_property';
      case PropertyCategory.primaryHome:
        return 'primary_home';
    }
  }

  /// Convert ListingType enum to string
  String _listingTypeToString(ListingType type) {
    switch (type) {
      case ListingType.karmaPoints:
        return 'karma_points';
      case ListingType.barter:
        return 'barter';
    }
  }
}
