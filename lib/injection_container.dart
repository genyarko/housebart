import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Services
import 'services/auth_service.dart';
import 'services/realtime_service.dart';
import 'services/property_service.dart';

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
import 'features/property/presentation/bloc/property_bloc.dart';

// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// Call this function in main.dart before runApp()
Future<void> init() async {
  //! Features - Authentication
  _initAuth();

  //! Features - Property
  _initProperty();

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

/// Initialize core services
Future<void> _initCore() async {
  // Supabase services
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => RealtimeService());
  sl.registerLazySingleton(() => PropertyService());

  // Note: Barter, Messaging, and other services will be added here as they're implemented
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
