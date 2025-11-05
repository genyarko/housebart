import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../property/domain/entities/property.dart';
import '../../../property/presentation/bloc/property_bloc.dart';
import '../../../property/presentation/bloc/property_event.dart';
import '../../../property/presentation/bloc/property_state.dart';
import '../bloc/matching_bloc.dart';
import '../bloc/matching_event.dart';
import '../bloc/matching_state.dart';

/// Page for creating a new barter request
class CreateBarterRequestPage extends StatefulWidget {
  final Property targetProperty;

  const CreateBarterRequestPage({
    super.key,
    required this.targetProperty,
  });

  @override
  State<CreateBarterRequestPage> createState() => _CreateBarterRequestPageState();
}

class _CreateBarterRequestPageState extends State<CreateBarterRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _requesterGuestsController = TextEditingController(text: '1');
  final _ownerGuestsController = TextEditingController(text: '1');

  Property? _selectedOfferProperty;
  DateTime? _requestedStartDate;
  DateTime? _requestedEndDate;
  DateTime? _offeredStartDate;
  DateTime? _offeredEndDate;

  bool _isLoading = false;
  List<Property> _userProperties = [];

  @override
  void initState() {
    super.initState();
    _loadUserProperties();
  }

  void _loadUserProperties() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PropertyBloc>().add(
            UserPropertiesLoadRequested(authState.user.id),
          );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _requesterGuestsController.dispose();
    _ownerGuestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Barter Request'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PropertyBloc, PropertyState>(
            listener: (context, state) {
              if (state is PropertiesLoaded) {
                setState(() {
                  _userProperties = state.properties;
                  if (_userProperties.isNotEmpty && _selectedOfferProperty == null) {
                    _selectedOfferProperty = _userProperties.first;
                  }
                });
              }
            },
          ),
          BlocListener<MatchingBloc, MatchingState>(
            listener: (context, state) {
              if (state is MatchingLoading) {
                setState(() => _isLoading = true);
              } else if (state is MatchingRequestCreated) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Barter request sent successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.pop(true);
              } else if (state is MatchingError) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<PropertyBloc, PropertyState>(
          builder: (context, propertyState) {
            if (propertyState is PropertyLoading && _userProperties.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_userProperties.isEmpty && propertyState is PropertiesEmpty) {
              return _buildNoPropertiesView();
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Target property info
                  _buildTargetPropertyCard(),
                  const SizedBox(height: 24),

                  // Select offer property
                  _buildSectionTitle('Your Property to Offer'),
                  const SizedBox(height: 12),
                  _buildOfferPropertySelector(),
                  const SizedBox(height: 24),

                  // Requested dates (when you want to stay at their property)
                  _buildSectionTitle('Your Stay Dates'),
                  const SizedBox(height: 8),
                  Text(
                    'When do you want to stay at ${widget.targetProperty.title}?',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRequestedDates(),
                  const SizedBox(height: 24),

                  // Offered dates (when they can stay at your property)
                  _buildSectionTitle('Offer Dates'),
                  const SizedBox(height: 8),
                  Text(
                    'When can they stay at ${_selectedOfferProperty?.title ?? 'your property'}?',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOfferedDates(),
                  const SizedBox(height: 24),

                  // Guest counts
                  _buildSectionTitle('Guest Details'),
                  const SizedBox(height: 12),
                  _buildGuestCounts(),
                  const SizedBox(height: 24),

                  // Message
                  _buildSectionTitle('Message (Optional)'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Add a message to the property owner...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),

                  // Summary
                  if (_requestedStartDate != null && _requestedEndDate != null)
                    _buildSummaryCard(),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Send Barter Request'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTargetPropertyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Property You Want',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.targetProperty.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.targetProperty.location.cityCountry,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferPropertySelector() {
    if (_userProperties.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warning),
        ),
        child: const Text(
          'You need to add a property before making a barter request',
          style: TextStyle(color: AppColors.warning),
        ),
      );
    }

    return DropdownButtonFormField<Property>(
      value: _selectedOfferProperty,
      decoration: const InputDecoration(
        labelText: 'Select your property',
        border: OutlineInputBorder(),
      ),
      items: _userProperties.map((property) {
        return DropdownMenuItem(
          value: property,
          child: Text(property.title),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedOfferProperty = value);
      },
      validator: (value) => value == null ? 'Please select a property' : null,
    );
  }

  Widget _buildRequestedDates() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: 'Check-in',
            date: _requestedStartDate,
            onTap: () => _selectDate(isRequestedStart: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField(
            label: 'Check-out',
            date: _requestedEndDate,
            onTap: () => _selectDate(isRequestedEnd: true),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferedDates() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: 'Check-in',
            date: _offeredStartDate,
            onTap: () => _selectDate(isOfferedStart: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField(
            label: 'Check-out',
            date: _offeredEndDate,
            onTap: () => _selectDate(isOfferedEnd: true),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select date',
          style: TextStyle(
            color: date != null ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGuestCounts() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _requesterGuestsController,
            decoration: const InputDecoration(
              labelText: 'Your guests',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final guests = int.tryParse(value);
              if (guests == null || guests < 1) return 'Min 1 guest';
              if (_selectedOfferProperty != null &&
                  guests > _selectedOfferProperty!.details.maxGuests) {
                return 'Max ${_selectedOfferProperty!.details.maxGuests}';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _ownerGuestsController,
            decoration: const InputDecoration(
              labelText: 'Their guests',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final guests = int.tryParse(value);
              if (guests == null || guests < 1) return 'Min 1 guest';
              if (guests > widget.targetProperty.details.maxGuests) {
                return 'Max ${widget.targetProperty.details.maxGuests}';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final requestedDays = _requestedEndDate!.difference(_requestedStartDate!).inDays;
    final offeredDays = _offeredEndDate != null && _offeredStartDate != null
        ? _offeredEndDate!.difference(_offeredStartDate!).inDays
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Your stay', '$requestedDays night${requestedDays != 1 ? 's' : ''}'),
          if (offeredDays > 0)
            _buildSummaryRow('Their stay', '$offeredDays night${offeredDays != 1 ? 's' : ''}'),
          const Divider(height: 24),
          if (offeredDays > 0 && (requestedDays - offeredDays).abs() > 2)
            Row(
              children: [
                const Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Duration difference may affect acceptance',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPropertiesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Properties Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You need to add at least one property before creating a barter request.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Future<void> _selectDate({
    bool isRequestedStart = false,
    bool isRequestedEnd = false,
    bool isOfferedStart = false,
    bool isOfferedEnd = false,
  }) async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));

    DateTime? initialDate;
    if (isRequestedStart) {
      initialDate = _requestedStartDate ?? now;
    } else if (isRequestedEnd) {
      initialDate = _requestedEndDate ?? _requestedStartDate?.add(const Duration(days: 1)) ?? now;
    } else if (isOfferedStart) {
      initialDate = _offeredStartDate ?? now;
    } else if (isOfferedEnd) {
      initialDate = _offeredEndDate ?? _offeredStartDate?.add(const Duration(days: 1)) ?? now;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isRequestedStart) {
          _requestedStartDate = selectedDate;
          // Reset end date if it's before start date
          if (_requestedEndDate != null && _requestedEndDate!.isBefore(_requestedStartDate!)) {
            _requestedEndDate = null;
          }
        } else if (isRequestedEnd) {
          _requestedEndDate = selectedDate;
        } else if (isOfferedStart) {
          _offeredStartDate = selectedDate;
          // Reset end date if it's before start date
          if (_offeredEndDate != null && _offeredEndDate!.isBefore(_offeredStartDate!)) {
            _offeredEndDate = null;
          }
        } else if (isOfferedEnd) {
          _offeredEndDate = selectedDate;
        }
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedOfferProperty == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a property to offer'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      if (_requestedStartDate == null || _requestedEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your stay dates'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      if (_offeredStartDate == null || _offeredEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select offer dates'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Validate dates
      if (!_requestedEndDate!.isAfter(_requestedStartDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out must be after check-in for your stay'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (!_offeredEndDate!.isAfter(_offeredStartDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out must be after check-in for offer dates'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<MatchingBloc>().add(
            MatchingCreateRequestEvent(
              requesterPropertyId: _selectedOfferProperty!.id,
              ownerPropertyId: widget.targetProperty.id,
              requestedStartDate: _requestedStartDate!,
              requestedEndDate: _requestedEndDate!,
              offeredStartDate: _offeredStartDate!,
              offeredEndDate: _offeredEndDate!,
              requesterGuests: int.parse(_requesterGuestsController.text.trim()),
              ownerGuests: int.parse(_ownerGuestsController.text.trim()),
              message: _messageController.text.trim().isNotEmpty
                  ? _messageController.text.trim()
                  : null,
            ),
          );
    }
  }
}
