import 'package:equatable/equatable.dart';

/// Entity representing a property verification request
class VerificationRequest extends Equatable {
  final String id;
  final String propertyId;
  final String userId;
  final VerificationStatus status;
  final String? paymentIntentId;
  final double? amount;
  final String? currency;
  final String? documentUrl;
  final String? adminNotes;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final DateTime? expiresAt;

  const VerificationRequest({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.status,
    this.paymentIntentId,
    this.amount,
    this.currency,
    this.documentUrl,
    this.adminNotes,
    this.rejectionReason,
    required this.createdAt,
    this.verifiedAt,
    this.expiresAt,
  });

  /// Check if verification is active (approved and not expired)
  bool get isActive {
    if (status != VerificationStatus.approved) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Check if verification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get days until expiration
  int? get daysUntilExpiration {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    return diff.inDays;
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        userId,
        status,
        paymentIntentId,
        amount,
        currency,
        documentUrl,
        adminNotes,
        rejectionReason,
        createdAt,
        verifiedAt,
        expiresAt,
      ];
}

/// Enum for verification request status
enum VerificationStatus {
  pending, // Awaiting payment
  paymentReceived, // Payment received, awaiting review
  underReview, // Being reviewed by admin
  approved, // Approved and active
  rejected, // Rejected by admin
  expired, // Verification expired
}

/// Extension for VerificationStatus enum
extension VerificationStatusExtension on VerificationStatus {
  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending Payment';
      case VerificationStatus.paymentReceived:
        return 'Payment Received';
      case VerificationStatus.underReview:
        return 'Under Review';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.expired:
        return 'Expired';
    }
  }

  String get description {
    switch (this) {
      case VerificationStatus.pending:
        return 'Complete payment to submit your verification request';
      case VerificationStatus.paymentReceived:
        return 'Payment received. Your request will be reviewed shortly';
      case VerificationStatus.underReview:
        return 'Your property is being verified by our team';
      case VerificationStatus.approved:
        return 'Your property has been verified';
      case VerificationStatus.rejected:
        return 'Your verification request was not approved';
      case VerificationStatus.expired:
        return 'Your verification has expired. Please submit a new request';
    }
  }

  static VerificationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'payment_received':
        return VerificationStatus.paymentReceived;
      case 'under_review':
        return VerificationStatus.underReview;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'expired':
        return VerificationStatus.expired;
      default:
        return VerificationStatus.pending;
    }
  }

  String toServerString() {
    switch (this) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.paymentReceived:
        return 'payment_received';
      case VerificationStatus.underReview:
        return 'under_review';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
      case VerificationStatus.expired:
        return 'expired';
    }
  }
}
