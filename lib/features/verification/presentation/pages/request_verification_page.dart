import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/verification_bloc.dart';
import '../bloc/verification_event.dart';
import '../bloc/verification_state.dart';

/// Page for requesting property verification
class RequestVerificationPage extends StatefulWidget {
  final String propertyId;

  const RequestVerificationPage({
    super.key,
    required this.propertyId,
  });

  @override
  State<RequestVerificationPage> createState() =>
      _RequestVerificationPageState();
}

class _RequestVerificationPageState extends State<RequestVerificationPage> {
  @override
  void initState() {
    super.initState();
    // Load existing verification for this property
    context.read<VerificationBloc>().add(
          VerificationLoadPropertyVerificationEvent(
            propertyId: widget.propertyId,
          ),
        );
  }

  void _createVerificationRequest() {
    context.read<VerificationBloc>().add(
          VerificationCreateRequestEvent(
            propertyId: widget.propertyId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Verification'),
      ),
      body: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state is VerificationRequestCreated) {
            // Navigate to payment page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification request created successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            // TODO: Navigate to payment page
            // context.push('/verification/payment/${state.request.id}');
          } else if (state is VerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VerificationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is VerificationPropertyVerificationLoaded) {
            final verification = state.request;

            if (verification != null && verification.isActive) {
              // Property is already verified
              return _buildVerifiedContent(verification.expiresAt);
            }

            // Show verification request form
            return _buildVerificationForm();
          }

          return _buildVerificationForm();
        },
      ),
    );
  }

  Widget _buildVerifiedContent(DateTime? expiresAt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified,
              size: 100,
              color: AppColors.success,
            ),
            const SizedBox(height: 24),
            Text(
              'Property Verified',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (expiresAt != null) ...[
              Text(
                'Expires on ${expiresAt.toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ] else ...[
              Text(
                'Lifetime verification',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Property'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify Your Property',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Property verification helps build trust with potential barter partners and increases your visibility.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          _buildBenefitsList(),
          const SizedBox(height: 32),
          _buildPricingInfo(),
          const SizedBox(height: 32),
          _buildRequirements(),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createVerificationRequest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Request Verification - \$29.99'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      'Verified badge on your property listing',
      'Increased visibility in search results',
      'Higher trust from potential partners',
      'Priority support from HouseBart',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benefits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(benefit),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingInfo() {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.payments,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$29.99 one-time fee',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verification valid for 1 year',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirements() {
    final requirements = [
      'Property must be owned by you',
      'Valid property documentation',
      'Clear property photos',
      'Accurate property information',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...requirements.map(
          (req) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    req,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
