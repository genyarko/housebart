import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/property.dart';

/// Card widget for displaying property in a list
class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final isVacationHome = property.propertyCategory == PropertyCategory.vacationHome;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: isVacationHome
            ? BorderSide(
                color: AppColors.accent,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            _buildImage(),

            // Property info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.location.city}, ${property.location.country}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Property specs
                  Text(
                    property.details.specsSummary,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badges row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(property.propertyCategory).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(property.propertyCategory),
                              size: 14,
                              color: _getCategoryColor(property.propertyCategory),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              property.propertyCategoryDisplay,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getCategoryColor(property.propertyCategory),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Verification badge
                      if (property.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Listing type badge (Karma or Barter)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: property.isKarmaListing
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusSmall,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              property.isKarmaListing ? Icons.bolt : Icons.sync,
                              size: 14,
                              color: property.isKarmaListing
                                  ? AppColors.accent
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              property.priceDisplay,
                              style: TextStyle(
                                fontSize: 12,
                                color: property.isKarmaListing
                                    ? AppColors.accent
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        // Property image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: property.primaryImage != null
              ? CachedNetworkImage(
                  imageUrl: property.primaryImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceLight,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    // Debug: Print error to console
                    debugPrint('Image load error for ${property.title}: $error');
                    debugPrint('Image URL: $url');
                    return Container(
                      color: AppColors.surfaceLight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image failed to load',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Container(
                  color: AppColors.surfaceLight,
                  child: const Icon(
                    Icons.home,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),

        // Favorite button (top right)
        if (onFavorite != null)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: onFavorite,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isFavorite ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),

        // Property type badge (bottom left)
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Text(
              property.details.propertyType,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get color for property category
  Color _getCategoryColor(PropertyCategory category) {
    switch (category) {
      case PropertyCategory.vacationHome:
        return AppColors.accent; // Golden for vacation homes
      case PropertyCategory.primaryHome:
        return AppColors.secondary; // Blue/teal for primary homes
      case PropertyCategory.spareProperty:
        return AppColors.primary; // Primary blue for spare properties
    }
  }

  /// Get icon for property category
  IconData _getCategoryIcon(PropertyCategory category) {
    switch (category) {
      case PropertyCategory.vacationHome:
        return Icons.beach_access; // Beach icon for vacation homes
      case PropertyCategory.primaryHome:
        return Icons.home; // Home icon for primary homes
      case PropertyCategory.spareProperty:
        return Icons.home_work; // Work/spare home icon
    }
  }
}
