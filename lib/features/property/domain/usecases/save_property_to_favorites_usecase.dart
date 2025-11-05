import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/property_repository.dart';

/// Use case for saving a property to favorites
class SavePropertyToFavoritesUseCase {
  final PropertyRepository repository;

  SavePropertyToFavoritesUseCase(this.repository);

  Future<Either<Failure, void>> call(SaveToFavoritesParams params) async {
    return await repository.savePropertyToFavorites(
      userId: params.userId,
      propertyId: params.propertyId,
    );
  }
}

/// Parameters for saving property to favorites
class SaveToFavoritesParams extends Equatable {
  final String userId;
  final String propertyId;

  const SaveToFavoritesParams({
    required this.userId,
    required this.propertyId,
  });

  @override
  List<Object> get props => [userId, propertyId];
}
