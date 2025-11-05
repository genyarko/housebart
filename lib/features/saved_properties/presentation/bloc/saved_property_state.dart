import 'package:equatable/equatable.dart';
import '../../../property/domain/entities/property.dart';

abstract class SavedPropertyState extends Equatable {
  const SavedPropertyState();

  @override
  List<Object?> get props => [];
}

class SavedPropertyInitial extends SavedPropertyState {}

class SavedPropertyLoading extends SavedPropertyState {}

class SavedPropertyLoaded extends SavedPropertyState {
  final List<Property> savedProperties;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final Map<String, bool> savedStatusCache;

  const SavedPropertyLoaded({
    required this.savedProperties,
    required this.totalCount,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.savedStatusCache = const {},
  });

  @override
  List<Object?> get props => [
        savedProperties,
        totalCount,
        hasMore,
        isLoadingMore,
        savedStatusCache,
      ];

  SavedPropertyLoaded copyWith({
    List<Property>? savedProperties,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    Map<String, bool>? savedStatusCache,
  }) {
    return SavedPropertyLoaded(
      savedProperties: savedProperties ?? this.savedProperties,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      savedStatusCache: savedStatusCache ?? this.savedStatusCache,
    );
  }
}

class SavedPropertyError extends SavedPropertyState {
  final String message;

  const SavedPropertyError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SavedPropertyActionSuccess extends SavedPropertyState {
  final String message;

  const SavedPropertyActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
