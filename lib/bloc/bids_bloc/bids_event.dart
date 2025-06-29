part of 'bids_bloc.dart';

sealed class BidsEvent extends Equatable {
  const BidsEvent();

  @override
  List<Object?> get props => [];
}

// Contractor bids events
final class ContractorBidsLoadRequested extends BidsEvent {
  final int page;
  final int perPage;
  final String? status;
  final String? search;
  final String? sortBy;
  final String? sortOrder;

  const ContractorBidsLoadRequested({
    this.page = 1,
    this.perPage = 10,
    this.status,
    this.search,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [page, perPage, status, search, sortBy, sortOrder];
}

final class ContractorBidsLoadMoreRequested extends BidsEvent {
  const ContractorBidsLoadMoreRequested();
}

final class ContractorBidsRefreshRequested extends BidsEvent {
  const ContractorBidsRefreshRequested();
}

// Project bids events (for clients)
final class ProjectBidsLoadRequested extends BidsEvent {
  final int projectId;
  final int page;
  final int perPage;

  const ProjectBidsLoadRequested({
    required this.projectId,
    this.page = 1,
    this.perPage = 10,
  });

  @override
  List<Object> get props => [projectId, page, perPage];
}

final class ProjectBidsLoadMoreRequested extends BidsEvent {
  final int projectId;

  const ProjectBidsLoadMoreRequested({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

final class ProjectBidsRefreshRequested extends BidsEvent {
  final int projectId;

  const ProjectBidsRefreshRequested({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

// Bid CRUD events
final class BidCreateRequested extends BidsEvent {
  final BidRequestModel bidRequest;

  const BidCreateRequested({required this.bidRequest});

  @override
  List<Object> get props => [bidRequest];
}

final class BidUpdateRequested extends BidsEvent {
  final int projectId;
  final int bidId;
  final BidRequestModel bidRequest;

  const BidUpdateRequested({
    required this.projectId,
    required this.bidId,
    required this.bidRequest,
  });

  @override
  List<Object> get props => [projectId, bidId, bidRequest];
}

final class BidDeleteRequested extends BidsEvent {
  final int projectId;
  final int bidId;

  const BidDeleteRequested({
    required this.projectId,
    required this.bidId,
  });

  @override
  List<Object> get props => [projectId, bidId];
}

final class BidLoadRequested extends BidsEvent {
  final int projectId;
  final int bidId;

  const BidLoadRequested({
    required this.projectId,
    required this.bidId,
  });

  @override
  List<Object> get props => [projectId, bidId];
}

// Filter events
final class BidsFilterChanged extends BidsEvent {
  final String? status;
  final String? search;

  const BidsFilterChanged({
    this.status,
    this.search,
  });

  @override
  List<Object?> get props => [status, search];
}
