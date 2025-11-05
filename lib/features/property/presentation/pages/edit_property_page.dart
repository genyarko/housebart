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
  late final TextEditingController _maxGuestsController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;

  late String _selectedPropertyType;
  late List<String> _selectedAmenities;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current property values
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController = TextEditingController(text: widget.property.description);
    _maxGuestsController = TextEditingController(text: widget.property.details.maxGuests.toString());
    _bedroomsController = TextEditingController(text: widget.property.details.bedrooms.toString());
    _bathroomsController = TextEditingController(text: widget.property.details.bathrooms.toString());

    _selectedPropertyType = widget.property.details.propertyType;
    _selectedAmenities = List.from(widget.property.amenities);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxGuestsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
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
                // Note about editing
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can update property details, but location cannot be changed.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Basic Information
                _buildSectionTitle('Basic Information'),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _titleController,
                  label: 'Property Title',
                  hint: 'Beautiful apartment in downtown',
                  validator: Validators.validatePropertyTitle,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
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

                // Property Details
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
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
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
                const SizedBox(height: 24),

                // Amenities
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

      // Build updates map with only changed fields
      final updates = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'property_type': _selectedPropertyType,
        'max_guests': int.parse(_maxGuestsController.text.trim()),
        'bedrooms': int.parse(_bedroomsController.text.trim()),
        'bathrooms': int.parse(_bathroomsController.text.trim()),
        'amenities': _selectedAmenities,
        'updated_at': DateTime.now().toIso8601String(),
      };

      context.read<PropertyBloc>().add(
            PropertyUpdateRequested(
              propertyId: widget.property.id,
              updates: updates,
            ),
          );
    }
  }
}
