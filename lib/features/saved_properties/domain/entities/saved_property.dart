import 'package:equatable/equatable.dart';

/// Entity representing a saved/favorited property
class SavedProperty extends Equatable {
  final String id;
  final String userId;
  final String propertyId;
  final DateTime createdAt;

  const SavedProperty({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, propertyId, createdAt];
}
