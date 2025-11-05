import '../../domain/entities/verification_request.dart';

/// Data model for VerificationRequest entity
class VerificationRequestModel extends VerificationRequest {
  const VerificationRequestModel({
    required super.id,
    required super.propertyId,
    required super.userId,
    required super.status,
    super.paymentIntentId,
    super.amount,
    super.currency,
    super.documentUrl,
    super.adminNotes,
    super.rejectionReason,
    required super.createdAt,
    super.verifiedAt,
    super.expiresAt,
  });

  /// Create model from JSON
  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      userId: json['user_id'] as String,
      status: VerificationStatusExtension.fromString(json['status'] as String),
      paymentIntentId: json['payment_intent_id'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] as String?,
      documentUrl: json['document_url'] as String?,
      adminNotes: json['admin_notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'user_id': userId,
      'status': status.toServerString(),
      'payment_intent_id': paymentIntentId,
      'amount': amount,
      'currency': currency,
      'document_url': documentUrl,
      'admin_notes': adminNotes,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Convert model to entity
  VerificationRequest toEntity() {
    return VerificationRequest(
      id: id,
      propertyId: propertyId,
      userId: userId,
      status: status,
      paymentIntentId: paymentIntentId,
      amount: amount,
      currency: currency,
      documentUrl: documentUrl,
      adminNotes: adminNotes,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      verifiedAt: verifiedAt,
      expiresAt: expiresAt,
    );
  }

  /// Create model from entity
  factory VerificationRequestModel.fromEntity(VerificationRequest entity) {
    return VerificationRequestModel(
      id: entity.id,
      propertyId: entity.propertyId,
      userId: entity.userId,
      status: entity.status,
      paymentIntentId: entity.paymentIntentId,
      amount: entity.amount,
      currency: entity.currency,
      documentUrl: entity.documentUrl,
      adminNotes: entity.adminNotes,
      rejectionReason: entity.rejectionReason,
      createdAt: entity.createdAt,
      verifiedAt: entity.verifiedAt,
      expiresAt: entity.expiresAt,
    );
  }
}
