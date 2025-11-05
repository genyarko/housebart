import '../../../../services/verification_service.dart';
import '../models/verification_request_model.dart';

/// Interface for verification remote data source
abstract class VerificationRemoteDataSource {
  Future<VerificationRequestModel> createRequest({
    required String propertyId,
  });

  Future<VerificationRequestModel> getRequestById({
    required String requestId,
  });

  Future<List<VerificationRequestModel>> getUserRequests();

  Future<VerificationRequestModel?> getPropertyVerification({
    required String propertyId,
  });

  Future<Map<String, dynamic>> createPaymentIntent({
    required String requestId,
  });

  Future<VerificationRequestModel> confirmPayment({
    required String requestId,
    required String paymentIntentId,
  });

  Future<String> uploadDocument({
    required String requestId,
    required String filePath,
  });

  Future<void> cancelRequest({
    required String requestId,
  });
}

/// Implementation of verification remote data source
class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final VerificationService verificationService;

  VerificationRemoteDataSourceImpl({
    required this.verificationService,
  });

  @override
  Future<VerificationRequestModel> createRequest({
    required String propertyId,
  }) async {
    final requestData = await verificationService.createRequest(
      propertyId: propertyId,
    );
    return VerificationRequestModel.fromJson(requestData);
  }

  @override
  Future<VerificationRequestModel> getRequestById({
    required String requestId,
  }) async {
    final requestData = await verificationService.getRequestById(
      requestId: requestId,
    );
    return VerificationRequestModel.fromJson(requestData);
  }

  @override
  Future<List<VerificationRequestModel>> getUserRequests() async {
    final requestsData = await verificationService.getUserRequests();
    return requestsData
        .map((data) => VerificationRequestModel.fromJson(data))
        .toList();
  }

  @override
  Future<VerificationRequestModel?> getPropertyVerification({
    required String propertyId,
  }) async {
    final requestData = await verificationService.getPropertyVerification(
      propertyId: propertyId,
    );

    if (requestData == null) return null;

    return VerificationRequestModel.fromJson(requestData);
  }

  @override
  Future<Map<String, dynamic>> createPaymentIntent({
    required String requestId,
  }) async {
    return await verificationService.createPaymentIntent(
      requestId: requestId,
    );
  }

  @override
  Future<VerificationRequestModel> confirmPayment({
    required String requestId,
    required String paymentIntentId,
  }) async {
    final requestData = await verificationService.confirmPayment(
      requestId: requestId,
      paymentIntentId: paymentIntentId,
    );
    return VerificationRequestModel.fromJson(requestData);
  }

  @override
  Future<String> uploadDocument({
    required String requestId,
    required String filePath,
  }) async {
    return await verificationService.uploadDocument(
      requestId: requestId,
      filePath: filePath,
    );
  }

  @override
  Future<void> cancelRequest({
    required String requestId,
  }) async {
    await verificationService.cancelRequest(requestId: requestId);
  }
}
