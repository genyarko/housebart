/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'HouseBart';
  static const String appTagline = 'Exchange homes, explore the world';

  // API & Network
  static const int apiTimeoutSeconds = 30;
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;

  // Pagination
  static const int defaultPageSize = 20;
  static const int searchResultsPageSize = 15;
  static const int maxLoadMoreAttempts = 3;

  // Image Configuration
  static const int maxImageSizeMB = 5;
  static const int maxImagesPerProperty = 10;
  static const int imageQuality = 85;
  static const double imageCompressionQuality = 0.8;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Property Configuration
  static const int minPropertyTitleLength = 10;
  static const int maxPropertyTitleLength = 100;
  static const int minPropertyDescriptionLength = 50;
  static const int maxPropertyDescriptionLength = 2000;
  static const int maxAmenities = 30;
  static const int minGuests = 1;
  static const int maxGuests = 20;
  static const int minBedrooms = 0;
  static const int maxBedrooms = 20;
  static const int minBathrooms = 1;
  static const int maxBathrooms = 10;

  // Barter Request Configuration
  static const int minBarterDays = 1;
  static const int maxBarterDays = 365;
  static const int minAdvanceBookingDays = 7;
  static const int maxBarterMessageLength = 500;

  // Review Configuration
  static const int minReviewLength = 20;
  static const int maxReviewLength = 1000;
  static const int minRating = 1;
  static const int maxRating = 5;

  // Verification
  static const double verificationFee = 49.99;
  static const String verificationFeeCurrency = 'USD';

  // Search & Filter
  static const int searchRadius = 50; // kilometers
  static const int maxSearchRadius = 500;
  static const int minSearchRadius = 5;

  // Messaging
  static const int maxMessageLength = 1000;
  static const int messagesPageSize = 50;

  // Cache Duration
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(hours: 24);

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Debounce Durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration typingDebounce = Duration(milliseconds: 300);

  // Property Types
  static const List<String> propertyTypes = [
    'apartment',
    'house',
    'villa',
    'condo',
    'cabin',
    'other',
  ];

  // Amenities
  static const List<String> commonAmenities = [
    'WiFi',
    'Air Conditioning',
    'Heating',
    'Kitchen',
    'Washer',
    'Dryer',
    'TV',
    'Parking',
    'Pool',
    'Hot Tub',
    'Gym',
    'Elevator',
    'Wheelchair Accessible',
    'Pets Allowed',
    'Smoking Allowed',
    'Balcony',
    'Garden',
    'Fireplace',
    'BBQ Grill',
    'Workspace',
  ];

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  // Validation Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String urlPattern =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
  static const String timeoutErrorMessage = 'Request timeout. Please try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registrationSuccessMessage = 'Registration successful!';
  static const String propertyCreatedMessage = 'Property created successfully!';
  static const String propertyUpdatedMessage = 'Property updated successfully!';
  static const String barterRequestSentMessage = 'Barter request sent!';
  static const String messageSentMessage = 'Message sent!';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Deep Link Paths
  static const String propertyDeepLinkPath = '/property/';
  static const String barterDeepLinkPath = '/barter/';
  static const String profileDeepLinkPath = '/profile/';
}
