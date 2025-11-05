import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/property_repository.dart';

/// Use case for removing a property from favorites
class RemovePropertyFromFavoritesUseCase {
  final PropertyRepository repository;

  RemovePropertyFromFavoritesUseCase(this.repository);

  Future<Either<Failure, void>> call(RemoveFromFavoritesParams params) async {
    return await repository.removePropertyFromFavorites(
      userId: params.userId,
      propertyId: params.propertyId,
    );
  }
}

/// Parameters for removing property from favorites
class RemoveFromFavoritesParams extends Equatable {
  final String userId;
  final String propertyId;

  const RemoveFromFavoritesParams({
    required this.userId,
    required this.propertyId,
  });

  @override
  List<Object> get props => [userId, propertyId];
}
