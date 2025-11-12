/// API routes and endpoints for app navigation
class ApiRoutes {
  // Private constructor to prevent instantiation
  ApiRoutes._();

  // Supabase Table Names
  static const String profilesTable = 'profiles';
  static const String propertiesTable = 'properties';
  static const String propertyImagesTable = 'property_images';
  static const String propertyAvailabilityTable = 'property_availability';
  static const String barterRequestsTable = 'barter_requests';
  static const String messagesTable = 'messages';
  static const String verificationRequestsTable = 'verification_requests';
  static const String reviewsTable = 'reviews';
  static const String savedPropertiesTable = 'saved_properties';
  static const String notificationsTable = 'notifications';

  // Supabase Storage Buckets
  static const String propertyImagesBucket = 'property-images';
  static const String userAvatarsBucket = 'user-avatars';
  static const String verificationDocsBucket = 'verification-documents';

  // Supabase RPC Functions
  static const String searchPropertiesNearbyRPC = 'search_properties_nearby';
  static const String checkPropertyAvailabilityRPC = 'check_property_availability';
  static const String createNotificationRPC = 'create_notification';

  // Edge Function Endpoints
  static const String createVerificationPaymentFunction = 'create-verification-payment';
  static const String stripeWebhookFunction = 'stripe-webhook';
  static const String sendNotificationFunction = 'send-notification';
}

/// App navigation routes
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main Routes
  static const String home = '/home';
  static const String explore = '/explore';
  static const String myProperties = '/my-properties';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Property Routes
  static const String properties = '/properties';
  static const String propertyDetails = '/property';
  static const String addProperty = '/property/add';
  static const String editProperty = '/property/edit';
  static const String propertyImages = '/property/images';

  // Barter Routes
  static const String createBarter = '/barter/create';
  static const String myBarters = '/barters/my-requests';
  static const String receivedBarters = '/barters/received';
  static const String barterDetails = '/barter/details';

  // Messaging Routes
  static const String conversations = '/conversations';
  static const String chat = '/chat/:barterId';

  // Verification Routes
  static const String requestVerification = '/verification/request/:propertyId';
  static const String verificationPayment = '/verification/payment/:requestId';
  static const String verificationStatus = '/verification/status/:requestId';

  // Review Routes
  static const String createReview = '/review/create/:barterId';
  static const String propertyReviews = '/property/:id/reviews';

  // Profile & Settings Routes
  static const String editProfile = '/profile/edit';
  static const String savedProperties = '/saved-properties';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';

  // Search & Filter Routes
  static const String search = '/search';
  static const String searchResults = '/search/results';
  static const String mapView = '/map';

  // Helper Methods
  static String propertyDetailsPath(String propertyId) =>
      '/property/$propertyId';

  static String editPropertyPath(String propertyId) =>
      '/property/$propertyId/edit';

  static String propertyImagesPath(String propertyId) =>
      '/property/$propertyId/images';

  static String barterDetailsPath(String barterId) => '/barter/$barterId';

  static String chatPath(String barterId) => '/chat/$barterId';

  static String requestVerificationPath(String propertyId) =>
      '/verification/request/$propertyId';

  static String verificationPaymentPath(String requestId) =>
      '/verification/payment/$requestId';

  static String verificationStatusPath(String requestId) =>
      '/verification/status/$requestId';

  static String createReviewPath(String barterId) =>
      '/review/create/$barterId';

  static String propertyReviewsPath(String propertyId) =>
      '/property/$propertyId/reviews';
}
