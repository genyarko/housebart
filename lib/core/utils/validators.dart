import '../constants/app_constants.dart';

/// Input validation utilities
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate property title
  static String? validatePropertyTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Property title is required';
    }

    if (value.length < AppConstants.minPropertyTitleLength) {
      return 'Title must be at least ${AppConstants.minPropertyTitleLength} characters';
    }

    if (value.length > AppConstants.maxPropertyTitleLength) {
      return 'Title must not exceed ${AppConstants.maxPropertyTitleLength} characters';
    }

    return null;
  }

  /// Validate property description
  static String? validatePropertyDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Property description is required';
    }

    if (value.length < AppConstants.minPropertyDescriptionLength) {
      return 'Description must be at least ${AppConstants.minPropertyDescriptionLength} characters';
    }

    if (value.length > AppConstants.maxPropertyDescriptionLength) {
      return 'Description must not exceed ${AppConstants.maxPropertyDescriptionLength} characters';
    }

    return null;
  }

  /// Validate number of guests
  static String? validateGuests(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of guests is required';
    }

    final guests = int.tryParse(value);
    if (guests == null) {
      return 'Please enter a valid number';
    }

    if (guests < AppConstants.minGuests) {
      return 'Minimum ${AppConstants.minGuests} guest';
    }

    if (guests > AppConstants.maxGuests) {
      return 'Maximum ${AppConstants.maxGuests} guests';
    }

    return null;
  }

  /// Validate number of bedrooms
  static String? validateBedrooms(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of bedrooms is required';
    }

    final bedrooms = int.tryParse(value);
    if (bedrooms == null) {
      return 'Please enter a valid number';
    }

    if (bedrooms < AppConstants.minBedrooms) {
      return 'Minimum ${AppConstants.minBedrooms} bedrooms';
    }

    if (bedrooms > AppConstants.maxBedrooms) {
      return 'Maximum ${AppConstants.maxBedrooms} bedrooms';
    }

    return null;
  }

  /// Validate number of bathrooms
  static String? validateBathrooms(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of bathrooms is required';
    }

    final bathrooms = int.tryParse(value);
    if (bathrooms == null) {
      return 'Please enter a valid number';
    }

    if (bathrooms < AppConstants.minBathrooms) {
      return 'Minimum ${AppConstants.minBathrooms} bathroom';
    }

    if (bathrooms > AppConstants.maxBathrooms) {
      return 'Maximum ${AppConstants.maxBathrooms} bathrooms';
    }

    return null;
  }

  /// Validate city
  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }
    if (value.trim().length < 2) {
      return 'City name must be at least 2 characters';
    }
    return null;
  }

  /// Validate country
  static String? validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Country is required';
    }
    if (value.trim().length < 2) {
      return 'Country name must be at least 2 characters';
    }
    return null;
  }

  /// Validate review
  static String? validateReview(String? value) {
    if (value == null || value.isEmpty) {
      return 'Review is required';
    }

    if (value.length < AppConstants.minReviewLength) {
      return 'Review must be at least ${AppConstants.minReviewLength} characters';
    }

    if (value.length > AppConstants.maxReviewLength) {
      return 'Review must not exceed ${AppConstants.maxReviewLength} characters';
    }

    return null;
  }

  /// Validate rating
  static String? validateRating(int? rating) {
    if (rating == null) {
      return 'Rating is required';
    }

    if (rating < AppConstants.minRating || rating > AppConstants.maxRating) {
      return 'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(AppConstants.urlPattern);
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate date range
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Please select both start and end dates';
    }

    if (endDate.isBefore(startDate)) {
      return 'End date must be after start date';
    }

    final duration = endDate.difference(startDate).inDays;
    if (duration < AppConstants.minBarterDays) {
      return 'Minimum booking duration is ${AppConstants.minBarterDays} day(s)';
    }

    if (duration > AppConstants.maxBarterDays) {
      return 'Maximum booking duration is ${AppConstants.maxBarterDays} days';
    }

    return null;
  }

  /// Validate advance booking
  static String? validateAdvanceBooking(DateTime? startDate) {
    if (startDate == null) {
      return 'Please select a start date';
    }

    final now = DateTime.now();
    final difference = startDate.difference(now).inDays;

    if (difference < AppConstants.minAdvanceBookingDays) {
      return 'Booking must be at least ${AppConstants.minAdvanceBookingDays} days in advance';
    }

    return null;
  }
}
