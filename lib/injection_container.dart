import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Services
import 'services/auth_service.dart';
import 'services/realtime_service.dart';
import 'services/property_service.dart';
import 'services/barter_service.dart';
import 'services/messaging_service.dart';
import 'services/verification_service.dart';
import 'services/notification_service.dart';
import 'services/saved_properties_service.dart';
import 'services/search_service.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Features - Property
import 'features/property/data/datasources/property_remote_datasource.dart';
import 'features/property/data/repositories/property_repository_impl.dart';
import 'features/property/domain/repositories/property_repository.dart';
import 'features/property/domain/usecases/create_property_usecase.dart';
import 'features/property/domain/usecases/get_properties_usecase.dart';
import 'features/property/domain/usecases/get_property_by_id_usecase.dart';
import 'features/property/domain/usecases/get_user_properties_usecase.dart';
import 'features/property/domain/usecases/delete_property_usecase.dart';
import 'features/property/domain/usecases/upload_property_images_usecase.dart';
import 'features/property/domain/usecases/get_favorite_properties_usecase.dart';
import 'features/property/domain/usecases/save_property_to_favorites_usecase.dart';
import 'features/property/domain/usecases/remove_property_from_favorites_usecase.dart';
import 'features/property/presentation/bloc/property_bloc.dart';

// Features - Matching/Barter
import 'features/matching/data/datasources/matching_remote_datasource.dart';
import 'features/matching/data/repositories/matching_repository_impl.dart';
import 'features/matching/domain/repositories/matching_repository.dart';
import 'features/matching/domain/usecases/create_barter_request_usecase.dart';
import 'features/matching/domain/usecases/accept_barter_usecase.dart';
import 'features/matching/domain/usecases/reject_barter_usecase.dart';
import 'features/matching/domain/usecases/cancel_barter_usecase.dart';
import 'features/matching/domain/usecases/get_my_requests_usecase.dart';
import 'features/matching/domain/usecases/get_received_requests_usecase.dart';
import 'features/matching/domain/usecases/find_matches_usecase.dart';
import 'features/matching/presentation/bloc/matching_bloc.dart';

// Features - Messaging
import 'features/messaging/data/datasources/messaging_remote_datasource.dart';
import 'features/messaging/data/repositories/messaging_repository_impl.dart';
import 'features/messaging/domain/repositories/messaging_repository.dart';
import 'features/messaging/domain/usecases/send_message_usecase.dart';
import 'features/messaging/domain/usecases/get_messages_usecase.dart';
import 'features/messaging/domain/usecases/get_conversations_usecase.dart';
import 'features/messaging/domain/usecases/mark_as_read_usecase.dart';
import 'features/messaging/presentation/bloc/messaging_bloc.dart';

// Features - Verification
import 'features/verification/data/datasources/verification_remote_datasource.dart';
import 'features/verification/data/repositories/verification_repository_impl.dart';
import 'features/verification/domain/repositories/verification_repository.dart';
import 'features/verification/domain/usecases/create_verification_request_usecase.dart';
import 'features/verification/domain/usecases/get_verification_request_by_id_usecase.dart';
import 'features/verification/domain/usecases/get_user_verification_requests_usecase.dart';
import 'features/verification/domain/usecases/get_property_verification_usecase.dart';
import 'features/verification/domain/usecases/create_payment_intent_usecase.dart';
import 'features/verification/domain/usecases/confirm_payment_usecase.dart';
import 'features/verification/presentation/bloc/verification_bloc.dart';

// Features - Notifications
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/get_notifications.dart';
import 'features/notifications/domain/usecases/get_unread_count.dart';
import 'features/notifications/domain/usecases/mark_as_read.dart';
import 'features/notifications/domain/usecases/mark_all_as_read.dart';
import 'features/notifications/domain/usecases/delete_notification.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

// Features - Saved Properties
import 'features/saved_properties/data/datasources/saved_property_remote_datasource.dart';
import 'features/saved_properties/data/repositories/saved_property_repository_impl.dart';
import 'features/saved_properties/domain/repositories/saved_property_repository.dart';
import 'features/saved_properties/domain/usecases/save_property.dart';
import 'features/saved_properties/domain/usecases/unsave_property.dart';
import 'features/saved_properties/domain/usecases/is_property_saved.dart';
import 'features/saved_properties/domain/usecases/get_saved_properties.dart';
import 'features/saved_properties/domain/usecases/get_saved_properties_count.dart';
import 'features/saved_properties/presentation/bloc/saved_property_bloc.dart';

// Features - Search
import 'features/search/data/datasources/search_remote_datasource.dart';
import 'features/search/data/repositories/search_repository_impl.dart';
import 'features/search/domain/repositories/search_repository.dart';
import 'features/search/domain/usecases/search_properties_usecase.dart';
import 'features/search/domain/usecases/get_search_suggestions_usecase.dart';
import 'features/search/presentation/bloc/search_bloc.dart';

// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// Call this function in main.dart before runApp()
Future<void> init() async {
  //! Features - Authentication
  _initAuth();

  //! Features - Property
  _initProperty();

  //! Features - Matching/Barter
  _initMatching();

  //! Features - Messaging
  _initMessaging();

  //! Features - Verification
  _initVerification();

  //! Features - Notifications
  _initNotifications();

  //! Features - Saved Properties
  _initSavedProperties();

  //! Features - Search
  _initSearch();

  //! Core Services
  await _initCore();

  //! External Dependencies
  await _initExternal();
}

/// Initialize authentication feature dependencies
void _initAuth() {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      forgotPasswordUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(authService: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

/// Initialize property feature dependencies
void _initProperty() {
  // Bloc
  sl.registerFactory(
    () => PropertyBloc(
      createPropertyUseCase: sl(),
      getPropertiesUseCase: sl(),
      getPropertyByIdUseCase: sl(),
      getUserPropertiesUseCase: sl(),
      deletePropertyUseCase: sl(),
      uploadPropertyImagesUseCase: sl(),
      getFavoritePropertiesUseCase: sl(),
      savePropertyToFavoritesUseCase: sl(),
      removePropertyFromFavoritesUseCase: sl(),
      propertyRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreatePropertyUseCase(sl()));
  sl.registerLazySingleton(() => GetPropertiesUseCase(sl()));
  sl.registerLazySingleton(() => GetPropertyByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetUserPropertiesUseCase(sl()));
  sl.registerLazySingleton(() => DeletePropertyUseCase(sl()));
  sl.registerLazySingleton(() => UploadPropertyImagesUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritePropertiesUseCase(sl()));
  sl.registerLazySingleton(() => SavePropertyToFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => RemovePropertyFromFavoritesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PropertyRemoteDataSource>(
    () => PropertyRemoteDataSourceImpl(propertyService: sl()),
  );
}

/// Initialize matching/barter feature dependencies
void _initMatching() {
  // Bloc
  sl.registerFactory(
    () => MatchingBloc(
      createBarterRequestUseCase: sl(),
      acceptBarterUseCase: sl(),
      rejectBarterUseCase: sl(),
      cancelBarterUseCase: sl(),
      getMyRequestsUseCase: sl(),
      getReceivedRequestsUseCase: sl(),
      matchingRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateBarterRequestUseCase(sl()));
  sl.registerLazySingleton(() => AcceptBarterUseCase(sl()));
  sl.registerLazySingleton(() => RejectBarterUseCase(sl()));
  sl.registerLazySingleton(() => CancelBarterUseCase(sl()));
  sl.registerLazySingleton(() => GetMyRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetReceivedRequestsUseCase(sl()));
  sl.registerLazySingleton(() => FindMatchesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<MatchingRepository>(
    () => MatchingRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<MatchingRemoteDataSource>(
    () => MatchingRemoteDataSourceImpl(barterService: sl()),
  );
}

/// Initialize messaging feature dependencies
void _initMessaging() {
  // Bloc
  sl.registerFactory(
    () => MessagingBloc(
      sendMessageUseCase: sl(),
      getMessagesUseCase: sl(),
      getConversationsUseCase: sl(),
      markAsReadUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));

  // Repository
  sl.registerLazySingleton<MessagingRepository>(
    () => MessagingRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<MessagingRemoteDataSource>(
    () => MessagingRemoteDataSourceImpl(messagingService: sl()),
  );
}

/// Initialize verification feature dependencies
void _initVerification() {
  // Bloc
  sl.registerFactory(
    () => VerificationBloc(
      createVerificationRequestUseCase: sl(),
      getVerificationRequestByIdUseCase: sl(),
      getUserVerificationRequestsUseCase: sl(),
      getPropertyVerificationUseCase: sl(),
      createPaymentIntentUseCase: sl(),
      confirmPaymentUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateVerificationRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetVerificationRequestByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetUserVerificationRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetPropertyVerificationUseCase(sl()));
  sl.registerLazySingleton(() => CreatePaymentIntentUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmPaymentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(verificationService: sl()),
  );
}

/// Initialize notifications feature dependencies
void _initNotifications() {
  // Bloc
  sl.registerFactory(
    () => NotificationBloc(
      getNotifications: sl(),
      getUnreadCount: sl(),
      markAsRead: sl(),
      markAllAsRead: sl(),
      deleteNotification: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => GetUnreadCount(sl()));
  sl.registerLazySingleton(() => MarkAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllAsRead(sl()));
  sl.registerLazySingleton(() => DeleteNotification(sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(notificationService: sl()),
  );
}

/// Initialize saved properties feature dependencies
void _initSavedProperties() {
  // Bloc
  sl.registerFactory(
    () => SavedPropertyBloc(
      getSavedProperties: sl(),
      getSavedPropertiesCount: sl(),
      saveProperty: sl(),
      unsaveProperty: sl(),
      isPropertySaved: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSavedProperties(sl()));
  sl.registerLazySingleton(() => GetSavedPropertiesCount(sl()));
  sl.registerLazySingleton(() => SaveProperty(sl()));
  sl.registerLazySingleton(() => UnsaveProperty(sl()));
  sl.registerLazySingleton(() => IsPropertySaved(sl()));

  // Repository
  sl.registerLazySingleton<SavedPropertyRepository>(
    () => SavedPropertyRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<SavedPropertyRemoteDataSource>(
    () => SavedPropertyRemoteDataSourceImpl(savedPropertiesService: sl()),
  );
}

/// Initialize search feature dependencies
void _initSearch() {
  // Bloc
  sl.registerFactory(
    () => SearchBloc(
      searchPropertiesUseCase: sl(),
      getSearchSuggestionsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchPropertiesUseCase(sl()));
  sl.registerLazySingleton(() => GetSearchSuggestionsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(searchService: sl()),
  );
}

/// Initialize core services
Future<void> _initCore() async {
  // Supabase services
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => RealtimeService());
  sl.registerLazySingleton(() => PropertyService());
  sl.registerLazySingleton(() => BarterService());
  sl.registerLazySingleton(() => MessagingService());
  sl.registerLazySingleton(() => VerificationService());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => SavedPropertiesService());
  sl.registerLazySingleton(() => SearchService());
}

/// Initialize external dependencies
Future<void> _initExternal() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Supabase client (already initialized in main.dart)
  sl.registerLazySingleton(() => Supabase.instance.client);
}

/// Clear all registrations (useful for testing)
Future<void> reset() async {
  await sl.reset();
}
