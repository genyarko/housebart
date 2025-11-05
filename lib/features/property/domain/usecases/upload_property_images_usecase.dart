import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/property_repository.dart';

/// Use case for uploading property images
class UploadPropertyImagesUseCase {
  final PropertyRepository repository;

  UploadPropertyImagesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call(
    UploadImagesParams params,
  ) async {
    return await repository.uploadPropertyImages(
      propertyId: params.propertyId,
      imagePaths: params.imagePaths,
      imageBytes: params.imageBytes,
    );
  }
}

/// Parameters for uploading images
class UploadImagesParams extends Equatable {
  final String propertyId;
  final List<String> imagePaths;
  final List<Uint8List>? imageBytes;

  const UploadImagesParams({
    required this.propertyId,
    required this.imagePaths,
    this.imageBytes,
  });

  @override
  List<Object?> get props => [propertyId, imagePaths, imageBytes];
}
