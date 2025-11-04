import '../../../../services/barter_service.dart';
import '../models/barter_request_model.dart';

/// Remote datasource for matching/barter operations
abstract class MatchingRemoteDataSource {
  Future<BarterRequestModel> createBarterRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
    required DateTime requestedStartDate,
    required DateTime requestedEndDate,
    required DateTime offeredStartDate,
    required DateTime offeredEndDate,
    required int requesterGuests,
    required int ownerGuests,
    String? message,
  });

  Future<BarterRequestModel> acceptBarterRequest(String requestId);

  Future<BarterRequestModel> rejectBarterRequest({
    required String requestId,
    String? reason,
  });

  Future<void> cancelBarterRequest(String requestId);

  Future<BarterRequestModel> completeBarterRequest(String requestId);

  Future<BarterRequestModel> getBarterRequestById(String requestId);

  Future<List<BarterRequestModel>> getMyBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  Future<List<BarterRequestModel>> getReceivedBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  Future<List<BarterRequestModel>> getPropertyBarterRequests({
    required String propertyId,
    String? status,
  });

  Future<List<String>> findMatches({
    required String userPropertyId,
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    int? minGuests,
  });

  Future<bool> checkExistingRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
  });

  Future<Map<String, dynamic>> getUserBarterStatistics();
}

/// Implementation of MatchingRemoteDataSource
class MatchingRemoteDataSourceImpl implements MatchingRemoteDataSource {
  final BarterService barterService;

  MatchingRemoteDataSourceImpl({required this.barterService});

  @override
  Future<BarterRequestModel> createBarterRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
    required DateTime requestedStartDate,
    required DateTime requestedEndDate,
    required DateTime offeredStartDate,
    required DateTime offeredEndDate,
    required int requesterGuests,
    required int ownerGuests,
    String? message,
  }) async {
    final barterData = await barterService.createBarterRequest(
      requesterPropertyId: requesterPropertyId,
      ownerPropertyId: ownerPropertyId,
      requestedStartDate: requestedStartDate,
      requestedEndDate: requestedEndDate,
      offeredStartDate: offeredStartDate,
      offeredEndDate: offeredEndDate,
      requesterGuests: requesterGuests,
      ownerGuests: ownerGuests,
      message: message,
    );

    return BarterRequestModel.fromJson(barterData);
  }

  @override
  Future<BarterRequestModel> acceptBarterRequest(String requestId) async {
    final barterData = await barterService.acceptBarterRequest(requestId);
    return BarterRequestModel.fromJson(barterData);
  }

  @override
  Future<BarterRequestModel> rejectBarterRequest({
    required String requestId,
    String? reason,
  }) async {
    final barterData = await barterService.rejectBarterRequest(
      requestId: requestId,
      reason: reason,
    );
    return BarterRequestModel.fromJson(barterData);
  }

  @override
  Future<void> cancelBarterRequest(String requestId) async {
    await barterService.cancelBarterRequest(requestId);
  }

  @override
  Future<BarterRequestModel> completeBarterRequest(String requestId) async {
    final barterData = await barterService.completeBarterRequest(requestId);
    return BarterRequestModel.fromJson(barterData);
  }

  @override
  Future<BarterRequestModel> getBarterRequestById(String requestId) async {
    final barterData = await barterService.getBarterRequestById(requestId);
    return BarterRequestModel.fromJson(barterData);
  }

  @override
  Future<List<BarterRequestModel>> getMyBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final bartersData = await barterService.getMyBarterRequests(
      status: status,
      limit: limit,
      offset: offset,
    );

    return bartersData.map((data) => BarterRequestModel.fromJson(data)).toList();
  }

  @override
  Future<List<BarterRequestModel>> getReceivedBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final bartersData = await barterService.getReceivedBarterRequests(
      status: status,
      limit: limit,
      offset: offset,
    );

    return bartersData.map((data) => BarterRequestModel.fromJson(data)).toList();
  }

  @override
  Future<List<BarterRequestModel>> getPropertyBarterRequests({
    required String propertyId,
    String? status,
  }) async {
    final bartersData = await barterService.getPropertyBarterRequests(
      propertyId: propertyId,
      status: status,
    );

    return bartersData.map((data) => BarterRequestModel.fromJson(data)).toList();
  }

  @override
  Future<List<String>> findMatches({
    required String userPropertyId,
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    int? minGuests,
  }) async {
    return await barterService.findMatches(
      userPropertyId: userPropertyId,
      city: city,
      country: country,
      startDate: startDate,
      endDate: endDate,
      minGuests: minGuests,
    );
  }

  @override
  Future<bool> checkExistingRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
  }) async {
    return await barterService.checkExistingRequest(
      requesterPropertyId: requesterPropertyId,
      ownerPropertyId: ownerPropertyId,
    );
  }

  @override
  Future<Map<String, dynamic>> getUserBarterStatistics() async {
    return await barterService.getUserBarterStatistics();
  }
}
