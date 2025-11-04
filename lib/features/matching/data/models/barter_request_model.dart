import '../../domain/entities/barter_request.dart';

/// Model for BarterRequest with JSON serialization
class BarterRequestModel extends BarterRequest {
  const BarterRequestModel({
    required super.id,
    required super.requesterId,
    required super.requesterPropertyId,
    required super.ownerId,
    required super.ownerPropertyId,
    required super.requestedStartDate,
    required super.requestedEndDate,
    required super.offeredStartDate,
    required super.offeredEndDate,
    required super.requesterGuests,
    required super.ownerGuests,
    super.message,
    required super.status,
    super.rejectionReason,
    required super.createdAt,
    super.updatedAt,
    super.expiresAt,
  });

  /// Create BarterRequestModel from JSON
  factory BarterRequestModel.fromJson(Map<String, dynamic> json) {
    return BarterRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      requesterPropertyId: json['requester_property_id'] as String,
      ownerId: json['owner_id'] as String,
      ownerPropertyId: json['owner_property_id'] as String,
      requestedStartDate: DateTime.parse(json['requested_start_date'] as String),
      requestedEndDate: DateTime.parse(json['requested_end_date'] as String),
      offeredStartDate: DateTime.parse(json['offered_start_date'] as String),
      offeredEndDate: DateTime.parse(json['offered_end_date'] as String),
      requesterGuests: json['requester_guests'] as int,
      ownerGuests: json['owner_guests'] as int,
      message: json['message'] as String?,
      status: _parseStatus(json['status'] as String),
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convert BarterRequestModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'requester_property_id': requesterPropertyId,
      'owner_id': ownerId,
      'owner_property_id': ownerPropertyId,
      'requested_start_date': requestedStartDate.toIso8601String(),
      'requested_end_date': requestedEndDate.toIso8601String(),
      'offered_start_date': offeredStartDate.toIso8601String(),
      'offered_end_date': offeredEndDate.toIso8601String(),
      'requester_guests': requesterGuests,
      'owner_guests': ownerGuests,
      'message': message,
      'status': _statusToString(status),
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Convert model to entity
  BarterRequest toEntity() {
    return BarterRequest(
      id: id,
      requesterId: requesterId,
      requesterPropertyId: requesterPropertyId,
      ownerId: ownerId,
      ownerPropertyId: ownerPropertyId,
      requestedStartDate: requestedStartDate,
      requestedEndDate: requestedEndDate,
      offeredStartDate: offeredStartDate,
      offeredEndDate: offeredEndDate,
      requesterGuests: requesterGuests,
      ownerGuests: ownerGuests,
      message: message,
      status: status,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: expiresAt,
    );
  }

  /// Create model from entity
  factory BarterRequestModel.fromEntity(BarterRequest entity) {
    return BarterRequestModel(
      id: entity.id,
      requesterId: entity.requesterId,
      requesterPropertyId: entity.requesterPropertyId,
      ownerId: entity.ownerId,
      ownerPropertyId: entity.ownerPropertyId,
      requestedStartDate: entity.requestedStartDate,
      requestedEndDate: entity.requestedEndDate,
      offeredStartDate: entity.offeredStartDate,
      offeredEndDate: entity.offeredEndDate,
      requesterGuests: entity.requesterGuests,
      ownerGuests: entity.ownerGuests,
      message: entity.message,
      status: entity.status,
      rejectionReason: entity.rejectionReason,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      expiresAt: entity.expiresAt,
    );
  }

  /// Parse status from string
  static BarterRequestStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BarterRequestStatus.pending;
      case 'accepted':
        return BarterRequestStatus.accepted;
      case 'rejected':
        return BarterRequestStatus.rejected;
      case 'cancelled':
        return BarterRequestStatus.cancelled;
      case 'completed':
        return BarterRequestStatus.completed;
      case 'expired':
        return BarterRequestStatus.expired;
      default:
        return BarterRequestStatus.pending;
    }
  }

  /// Convert status to string
  static String _statusToString(BarterRequestStatus status) {
    switch (status) {
      case BarterRequestStatus.pending:
        return 'pending';
      case BarterRequestStatus.accepted:
        return 'accepted';
      case BarterRequestStatus.rejected:
        return 'rejected';
      case BarterRequestStatus.cancelled:
        return 'cancelled';
      case BarterRequestStatus.completed:
        return 'completed';
      case BarterRequestStatus.expired:
        return 'expired';
    }
  }
}
