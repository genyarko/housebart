import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/get_profile_statistics_usecase.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {
  final String userId;

  const ProfileLoadEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateEvent extends ProfileEvent {
  final String? fullName;
  final String? phone;
  final String? bio;
  final String? location;

  const ProfileUpdateEvent({
    this.fullName,
    this.phone,
    this.bio,
    this.location,
  });

  @override
  List<Object?> get props => [fullName, phone, bio, location];
}

class ProfileStatisticsLoadEvent extends ProfileEvent {
  final String userId;

  const ProfileStatisticsLoadEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileStatistics extends ProfileState {
  final int propertiesCount;
  final int bartersCount;
  final int savedCount;

  const ProfileStatistics({
    required this.propertiesCount,
    required this.bartersCount,
    required this.savedCount,
  });

  @override
  List<Object?> get props => [propertiesCount, bartersCount, savedCount];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetProfileStatisticsUseCase getProfileStatisticsUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
    required this.getProfileStatisticsUseCase,
  }) : super(ProfileInitial()) {
    on<ProfileLoadEvent>(_onLoadProfile);
    on<ProfileUpdateEvent>(_onUpdateProfile);
    on<ProfileStatisticsLoadEvent>(_onLoadStatistics);
  }

  Future<void> _onLoadProfile(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getUserProfileUseCase(
      GetUserProfileParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await updateProfileUseCase(
      UpdateProfileParams(
        fullName: event.fullName,
        phone: event.phone,
        bio: event.bio,
        location: event.location,
      ),
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileUpdated(profile)),
    );
  }

  Future<void> _onLoadStatistics(
    ProfileStatisticsLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await getProfileStatisticsUseCase(
      GetProfileStatisticsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (stats) => emit(ProfileStatistics(
        propertiesCount: stats['properties'] ?? 0,
        bartersCount: stats['barters'] ?? 0,
        savedCount: stats['saved'] ?? 0,
      )),
    );
  }
}
