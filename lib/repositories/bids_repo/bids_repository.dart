import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/bids/bid_model.dart';
import '../../models/pagination/pagination_model.dart';
import 'bids_provider.dart';

class BidsRepository {
  final FlutterSecureStorage storage;
  final BidsProvider bidsProvider;

  BidsRepository({
    required this.storage,
    required this.bidsProvider,
  });

  Future<PaginationModel<BidModel>> getContractorBids({
    int page = 1,
    int perPage = 10,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    return await bidsProvider.getContractorBids(
      page: page,
      perPage: perPage,
      status: status,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  Future<PaginationModel<BidModel>> getProjectBids(
    int projectId, {
    int page = 1,
    int perPage = 10,
  }) async {
    return await bidsProvider.getProjectBids(
      projectId,
      page: page,
      perPage: perPage,
    );
  }

  Future<BidModel> createBid(BidRequestModel bidRequest) async {
    return await bidsProvider.createBid(bidRequest);
  }

  Future<BidModel> updateBid(
    int projectId,
    int bidId,
    BidRequestModel bidRequest,
  ) async {
    return await bidsProvider.updateBid(projectId, bidId, bidRequest);
  }

  Future<void> deleteBid(int projectId, int bidId) async {
    await bidsProvider.deleteBid(projectId, bidId);
  }

  Future<BidModel?> getBid(int projectId, int bidId) async {
    return await bidsProvider.getBid(projectId, bidId);
  }
}
