# Flutter Accommodation Bartering App - Implementation

## Project Structure

```
barter_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_strings.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   └── network_info.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── extensions.dart
│   │   └── widgets/
│   │       ├── loading_widget.dart
│   │       ├── error_widget.dart
│   │       └── custom_button.dart
│   ├── features/
│   │   ├── auth/
│   │   ├── property/
│   │   ├── matching/
│   │   ├── messaging/
│   │   └── verification/
│   ├── injection_container.dart
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

## Core Implementation Files

### 1. main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const BarterApp());
}

class BarterApp extends StatelessWidget {
  const BarterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus())),
      ],
      child: MaterialApp.router(
        title: 'Barter App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

### 2. injection_container.dart
```dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    registerUseCase: sl(),
    logoutUseCase: sl(),
    getCurrentUserUseCase: sl(),
  ));
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      localStorage: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => ApiClient(sl()));
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
```

### 3. Core Layer Implementation

#### core/errors/failures.dart
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

#### core/network/api_client.dart
```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio _dio;
  static const String _tokenKey = 'auth_token';
  
  ApiClient(this._dio) {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle token refresh here
          await _refreshToken();
          // Retry the request
          handler.resolve(await _retry(error.requestOptions));
        } else {
          handler.next(error);
        }
      },
    ));
  }
  
  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  Future<void> _refreshToken() async {
    // Implement token refresh logic
  }
  
  Dio get dio => _dio;
}
```

### 4. Authentication Feature Implementation

#### domain/entities/user.dart
```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
  final bool isVerified;
  final DateTime createdAt;
  
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.isVerified,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, email, firstName, lastName, avatar, isVerified, createdAt];
}
```

#### domain/repositories/auth_repository.dart
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, User>> getCurrentUser();
  
  Future<Either<Failure, bool>> isLoggedIn();
}
```

#### data/models/user_model.dart
```dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? avatar,
    required bool isVerified,
    required DateTime createdAt,
  }) : super(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    avatar: avatar,
    isVerified: isVerified,
    createdAt: createdAt,
  );
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

#### presentation/bloc/auth_bloc.dart
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({required this.email, required this.password});
  
  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
  
  @override
  List<Object> get props => [email, password, firstName, lastName];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  
  const Authenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }
  
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
    ));
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }
  
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await logoutUseCase(NoParams());
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }
  
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await getCurrentUserUseCase(NoParams());
    
    result.fold(
      (_) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }
}
```

### 5. Property Feature Implementation

#### property/domain/entities/property.dart
```dart
import 'package:equatable/equatable.dart';

class Property extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final PropertyLocation location;
  final List<String> images;
  final List<String> amenities;
  final PropertyDetails details;
  final VerificationStatus verificationStatus;
  final List<DateRange> availableDates;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.location,
    required this.images,
    required this.amenities,
    required this.details,
    required this.verificationStatus,
    required this.availableDates,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object> get props => [
    id,
    ownerId,
    title,
    description,
    location,
    images,
    amenities,
    details,
    verificationStatus,
    availableDates,
    createdAt,
    updatedAt,
  ];
}

class PropertyLocation extends Equatable {
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  
  const PropertyLocation({
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
  
  @override
  List<Object> get props => [address, city, country, latitude, longitude];
}

class PropertyDetails extends Equatable {
  final String propertyType;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final double area;
  
  const PropertyDetails({
    required this.propertyType,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
  });
  
  @override
  List<Object> get props => [propertyType, maxGuests, bedrooms, bathrooms, area];
}

class DateRange extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  
  const DateRange({
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object> get props => [startDate, endDate];
}

enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
}
```

#### property/presentation/pages/property_listing_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/property_bloc.dart';
import '../widgets/property_card.dart';

class PropertyListingPage extends StatelessWidget {
  const PropertyListingPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PropertyLoaded) {
            if (state.properties.isEmpty) {
              return const Center(
                child: Text('No properties available'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PropertyBloc>().add(LoadProperties());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.properties.length,
                itemBuilder: (context, index) {
                  return PropertyCard(property: state.properties[index]);
                },
              ),
            );
          } else if (state is PropertyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PropertyBloc>().add(LoadProperties());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-property'),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PropertyFilterSheet(),
    );
  }
}
```

### 6. Matching/Bartering Feature

#### matching/domain/entities/barter_request.dart
```dart
import 'package:equatable/equatable.dart';

class BarterRequest extends Equatable {
  final String id;
  final String requesterId;
  final String offerPropertyId;
  final String targetPropertyId;
  final DateRange proposedDates;
  final BarterStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const BarterRequest({
    required this.id,
    required this.requesterId,
    required this.offerPropertyId,
    required this.targetPropertyId,
    required this.proposedDates,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    requesterId,
    offerPropertyId,
    targetPropertyId,
    proposedDates,
    status,
    message,
    createdAt,
    updatedAt,
  ];
}

enum BarterStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  completed,
}

class DateRange extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  
  const DateRange({
    required this.startDate,
    required this.endDate,
  });
  
  bool overlaps(DateRange other) {
    return startDate.isBefore(other.endDate) && 
           endDate.isAfter(other.startDate);
  }
  
  @override
  List<Object> get props => [startDate, endDate];
}
```

#### matching/presentation/pages/create_barter_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/matching_bloc.dart';

class CreateBarterPage extends StatefulWidget {
  final String targetPropertyId;
  
  const CreateBarterPage({
    Key? key,
    required this.targetPropertyId,
  }) : super(key: key);
  
  @override
  State<CreateBarterPage> createState() => _CreateBarterPageState();
}

class _CreateBarterPageState extends State<CreateBarterPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  
  String? _selectedPropertyId;
  DateTimeRange? _selectedDateRange;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Barter Request'),
      ),
      body: BlocConsumer<MatchingBloc, MatchingState>(
        listener: (context, state) {
          if (state is BarterRequestCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Barter request sent successfully')),
            );
            Navigator.pop(context);
          } else if (state is MatchingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Your Property',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPropertySelector(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Dates',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDateRangePicker(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Message (Optional)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Add a personal message to the owner',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state is MatchingLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: state is MatchingLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send Barter Request'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPropertySelector() {
    // Implement property dropdown selector
    return DropdownButtonFormField<String>(
      value: _selectedPropertyId,
      decoration: const InputDecoration(
        labelText: 'Your Property',
        border: OutlineInputBorder(),
      ),
      items: [], // Load user's properties
      onChanged: (value) {
        setState(() {
          _selectedPropertyId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a property';
        }
        return null;
      },
    );
  }
  
  Widget _buildDateRangePicker() {
    return InkWell(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        
        if (picked != null) {
          setState(() {
            _selectedDateRange = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Exchange Dates',
          border: OutlineInputBorder(),
        ),
        child: Text(
          _selectedDateRange == null
              ? 'Select dates'
              : '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}',
        ),
      ),
    );
  }
  
  void _submitRequest() {
    if (_formKey.currentState!.validate() && _selectedDateRange != null) {
      context.read<MatchingBloc>().add(
        CreateBarterRequest(
          offerPropertyId: _selectedPropertyId!,
          targetPropertyId: widget.targetPropertyId,
          startDate: _selectedDateRange!.start,
          endDate: _selectedDateRange!.end,
          message: _messageController.text.trim(),
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
```

### 7. Verification Feature

#### verification/presentation/pages/verification_request_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/verification_bloc.dart';

class VerificationRequestPage extends StatelessWidget {
  final String propertyId;
  
  const VerificationRequestPage({
    Key? key,
    required this.propertyId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Verification'),
      ),
      body: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state is VerificationPaymentSuccess) {
            Navigator.pushReplacementNamed(
              context,
              '/verification-status',
              arguments: state.requestId,
            );
          } else if (state is VerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verification Benefits',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBenefitItem(
                          Icons.verified_user,
                          'Verified Badge',
                          'Get a verified badge on your property listing',
                        ),
                        _buildBenefitItem(
                          Icons.trending_up,
                          'Higher Visibility',
                          'Verified properties appear higher in search results',
                        ),
                        _buildBenefitItem(
                          Icons.people,
                          'More Trust',
                          'Users are more likely to barter with verified properties',
                        ),
                        _buildBenefitItem(
                          Icons.support_agent,
                          'Priority Support',
                          'Get priority customer support for verified properties',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verification Process',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProcessStep(
                          1,
                          'Submit Request',
                          'Submit your verification request with payment',
                        ),
                        _buildProcessStep(
                          2,
                          'Document Review',
                          'Our team reviews your property documents',
                        ),
                        _buildProcessStep(
                          3,
                          'Property Inspection',
                          'Virtual or physical inspection of your property',
                        ),
                        _buildProcessStep(
                          4,
                          'Verification Complete',
                          'Receive your verification badge within 48 hours',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Verification Fee',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '\$49.99',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'One-time payment',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state is VerificationLoading
                      ? null
                      : () => _proceedToPayment(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: state is VerificationLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Proceed to Payment',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProcessStep(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            child: Text('$step'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _proceedToPayment(BuildContext context) {
    context.read<VerificationBloc>().add(
      RequestVerification(propertyId: propertyId),
    );
  }
}
```

## Testing Implementation

### Unit Tests

```dart
// test/features/auth/domain/usecases/login_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });
  
  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tUser = User(
    id: '1',
    email: tEmail,
    firstName: 'John',
    lastName: 'Doe',
    isVerified: true,
    createdAt: DateTime.now(),
  );
  
  test('should get user from repository', () async {
    // arrange
    when(mockRepository.login(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => const Right(tUser));
    
    // act
    final result = await usecase(const LoginParams(
      email: tEmail,
      password: tPassword,
    ));
    
    // assert
    expect(result, const Right(tUser));
    verify(mockRepository.login(email: tEmail, password: tPassword));
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### Widget Tests

```dart
// test/features/auth/presentation/pages/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  
  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });
  
  Widget makeTestableWidget(Widget child) {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(home: child),
    );
  }
  
  testWidgets('should show email and password fields', 
    (WidgetTester tester) async {
    // arrange
    when(mockAuthBloc.state).thenReturn(AuthInitial());
    
    // act
    await tester.pumpWidget(makeTestableWidget(const LoginPage()));
    
    // assert
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
  
  testWidgets('should trigger login when button is pressed', 
    (WidgetTester tester) async {
    // arrange
    when(mockAuthBloc.state).thenReturn(AuthInitial());
    
    // act
    await tester.pumpWidget(makeTestableWidget(const LoginPage()));
    
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@test.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    // assert
    verify(mockAuthBloc.add(const LoginRequested(
      email: 'test@test.com',
      password: 'password123',
    ))).called(1);
  });
}
```

## Configuration Files

### pubspec.yaml
```yaml
name: barter_app
description: Accommodation bartering system
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.0
  injectable: ^2.3.0
  
  # Network
  dio: ^5.3.2
  retrofit: ^4.0.3
  internet_connection_checker: ^1.0.0
  
  # Local Storage
  shared_preferences: ^2.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Navigation
  go_router: ^12.0.0
  
  # Utils
  dartz: ^0.10.1
  intl: ^0.18.1
  uuid: ^4.1.0
  
  # UI Components
  cached_network_image: ^3.3.0
  flutter_map: ^5.0.0
  image_picker: ^1.0.4
  flutter_svg: ^2.0.7
  shimmer: ^3.0.0
  
  # Forms
  flutter_form_builder: ^9.1.0
  form_builder_validators: ^9.0.0
  
  # Payments
  flutter_stripe: ^9.5.0
  
  # Firebase (optional)
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  firebase_messaging: ^14.7.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  mockito: ^5.4.0
  injectable_generator: ^2.4.0
  retrofit_generator: ^8.0.0
  hive_generator: ^2.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Poppins
      fonts:
        - asset: fonts/Poppins-Regular.ttf
        - asset: fonts/Poppins-Bold.ttf
          weight: 700
```

This implementation provides a solid foundation for your accommodation bartering Flutter app with clean architecture principles!
