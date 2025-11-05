import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../property/domain/entities/property.dart';

/// Repository interface for saved property operations
abstract class SavedPropertyRepository {
  /// Save/favorite a property
  Future<Either<Failure, void>> saveProperty({required String propertyId});

  /// Unsave/unfavorite a property
  Future<Either<Failure, void>> unsaveProperty({required String propertyId});

  /// Check if a property is saved
  Future<Either<Failure, bool>> isPropertySaved({required String propertyId});

  /// Get all saved properties for the current user
  Future<Either<Failure, List<Property>>> getSavedProperties({
    int limit = 50,
    int offset = 0,
  });

  /// Get count of saved properties
  Future<Either<Failure, int>> getSavedPropertiesCount();
}
