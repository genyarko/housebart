import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Widget to display property amenities with icons
class PropertyAmenitiesList extends StatelessWidget {
  final List<String> amenities;
  final int maxVisible;
  final bool showAll;

  const PropertyAmenitiesList({
    super.key,
    required this.amenities,
    this.maxVisible = 6,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const Text(
        'No amenities listed',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      );
    }

    final displayAmenities = showAll ? amenities : amenities.take(maxVisible).toList();
    final remainingCount = amenities.length - maxVisible;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...displayAmenities.map((amenity) => _buildAmenityChip(amenity)),
        if (!showAll && remainingCount > 0)
          _buildMoreChip(remainingCount),
      ],
    );
  }

  Widget _buildAmenityChip(String amenity) {
    final icon = _getAmenityIcon(amenity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            amenity,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(
          color: AppColors.primary,
          width: 1,
        ),
      ),
      child: Text(
        '+$count more',
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    final amenityLower = amenity.toLowerCase();

    // WiFi
    if (amenityLower.contains('wifi') || amenityLower.contains('internet')) {
      return Icons.wifi;
    }
    // Kitchen
    if (amenityLower.contains('kitchen')) {
      return Icons.kitchen;
    }
    // Parking
    if (amenityLower.contains('parking') || amenityLower.contains('garage')) {
      return Icons.local_parking;
    }
    // Pool
    if (amenityLower.contains('pool')) {
      return Icons.pool;
    }
    // AC / Heating
    if (amenityLower.contains('ac') || amenityLower.contains('air conditioning')) {
      return Icons.ac_unit;
    }
    if (amenityLower.contains('heating')) {
      return Icons.local_fire_department;
    }
    // Washer / Dryer
    if (amenityLower.contains('washer') || amenityLower.contains('laundry')) {
      return Icons.local_laundry_service;
    }
    // TV
    if (amenityLower.contains('tv') || amenityLower.contains('television')) {
      return Icons.tv;
    }
    // Gym
    if (amenityLower.contains('gym') || amenityLower.contains('fitness')) {
      return Icons.fitness_center;
    }
    // Pet friendly
    if (amenityLower.contains('pet')) {
      return Icons.pets;
    }
    // Balcony / Patio
    if (amenityLower.contains('balcony') || amenityLower.contains('patio')) {
      return Icons.balcony;
    }
    // Garden
    if (amenityLower.contains('garden') || amenityLower.contains('yard')) {
      return Icons.yard;
    }
    // Fireplace
    if (amenityLower.contains('fireplace')) {
      return Icons.fireplace;
    }
    // Elevator
    if (amenityLower.contains('elevator') || amenityLower.contains('lift')) {
      return Icons.elevator;
    }
    // Workspace
    if (amenityLower.contains('workspace') || amenityLower.contains('desk')) {
      return Icons.desk;
    }
    // Security
    if (amenityLower.contains('security') || amenityLower.contains('alarm')) {
      return Icons.security;
    }
    // Accessible
    if (amenityLower.contains('accessible') || amenityLower.contains('wheelchair')) {
      return Icons.accessible;
    }
    // BBQ
    if (amenityLower.contains('bbq') || amenityLower.contains('grill')) {
      return Icons.outdoor_grill;
    }

    // Default icon
    return Icons.check_circle_outline;
  }
}
