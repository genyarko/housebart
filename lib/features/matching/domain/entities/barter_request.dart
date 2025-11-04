import 'package:equatable/equatable.dart';

/// Enum for barter request status
enum BarterRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  completed,
  expired;

  String get displayName {
    switch (this) {
      case BarterRequestStatus.pending:
        return 'Pending';
      case BarterRequestStatus.accepted:
        return 'Accepted';
      case BarterRequestStatus.rejected:
        return 'Rejected';
      case BarterRequestStatus.cancelled:
        return 'Cancelled';
      case BarterRequestStatus.completed:
        return 'Completed';
      case BarterRequestStatus.expired:
        return 'Expired';
    }
  }

  bool get isActive => this == BarterRequestStatus.pending || this == BarterRequestStatus.accepted;
  bool get isPending => this == BarterRequestStatus.pending;
  bool get isAccepted => this == BarterRequestStatus.accepted;
  bool get canCancel => this == BarterRequestStatus.pending || this == BarterRequestStatus.accepted;
  bool get canAccept => this == BarterRequestStatus.pending;
  bool get canReject => this == BarterRequestStatus.pending;
}

/// Entity representing a barter request (exchange proposal)
class BarterRequest extends Equatable {
  final String id;
  final String requesterId; // User who initiated the request
  final String requesterPropertyId; // Property offered by requester
  final String ownerId; // Owner of the desired property
  final String ownerPropertyId; // Property desired by requester
  final DateTime requestedStartDate; // Desired check-in date
  final DateTime requestedEndDate; // Desired check-out date
  final DateTime offeredStartDate; // Offered check-in date
  final DateTime offeredEndDate; // Offered check-out date
  final int requesterGuests; // Number of guests from requester
  final int ownerGuests; // Number of guests from owner
  final String? message; // Optional message from requester
  final BarterRequestStatus status;
  final String? rejectionReason; // Reason for rejection (if any)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt; // Request expiration date

  const BarterRequest({
    required this.id,
    required this.requesterId,
    required this.requesterPropertyId,
    required this.ownerId,
    required this.ownerPropertyId,
    required this.requestedStartDate,
    required this.requestedEndDate,
    required this.offeredStartDate,
    required this.offeredEndDate,
    required this.requesterGuests,
    required this.ownerGuests,
    this.message,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
        id,
        requesterId,
        requesterPropertyId,
        ownerId,
        ownerPropertyId,
        requestedStartDate,
        requestedEndDate,
        offeredStartDate,
        offeredEndDate,
        requesterGuests,
        ownerGuests,
        message,
        status,
        rejectionReason,
        createdAt,
        updatedAt,
        expiresAt,
      ];

  /// Calculate the duration of requested stay in days
  int get requestedDuration => requestedEndDate.difference(requestedStartDate).inDays;

  /// Calculate the duration of offered stay in days
  int get offeredDuration => offeredEndDate.difference(offeredStartDate).inDays;

  /// Check if the barter is fair (similar durations)
  bool get isFairExchange {
    final durationDiff = (requestedDuration - offeredDuration).abs();
    return durationDiff <= 2; // Allow 2 days difference
  }

  /// Check if the request has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time remaining until expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  /// Check if dates overlap with another request
  bool overlapsWithRequested(DateTime start, DateTime end) {
    return !(end.isBefore(requestedStartDate) || start.isAfter(requestedEndDate));
  }

  /// Check if offered dates overlap
  bool overlapsWithOffered(DateTime start, DateTime end) {
    return !(end.isBefore(offeredStartDate) || start.isAfter(offeredEndDate));
  }

  /// Create a copy with updated fields
  BarterRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterPropertyId,
    String? ownerId,
    String? ownerPropertyId,
    DateTime? requestedStartDate,
    DateTime? requestedEndDate,
    DateTime? offeredStartDate,
    DateTime? offeredEndDate,
    int? requesterGuests,
    int? ownerGuests,
    String? message,
    BarterRequestStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return BarterRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterPropertyId: requesterPropertyId ?? this.requesterPropertyId,
      ownerId: ownerId ?? this.ownerId,
      ownerPropertyId: ownerPropertyId ?? this.ownerPropertyId,
      requestedStartDate: requestedStartDate ?? this.requestedStartDate,
      requestedEndDate: requestedEndDate ?? this.requestedEndDate,
      offeredStartDate: offeredStartDate ?? this.offeredStartDate,
      offeredEndDate: offeredEndDate ?? this.offeredEndDate,
      requesterGuests: requesterGuests ?? this.requesterGuests,
      ownerGuests: ownerGuests ?? this.ownerGuests,
      message: message ?? this.message,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
