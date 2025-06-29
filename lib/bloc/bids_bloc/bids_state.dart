part of 'bids_bloc.dart';

sealed class BidsState extends Equatable {
  const BidsState();

  @override
  List<Object?> get props => [];
}

final class BidsInitial extends BidsState {}

final class BidsLoading extends BidsState {}

final class BidsLoadingMore extends BidsState {}

final class BidsRefreshing extends BidsState {}

// Contractor bids states
final class ContractorBidsLoaded extends BidsState {
  final PaginationModel<BidModel> bids;
  final bool hasReachedMax;
  final String? statusFilter;
  final String? searchQuery;

  const ContractorBidsLoaded({
    required this.bids,
    required this.hasReachedMax,
    this.statusFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [bids, hasReachedMax, statusFilter, searchQuery];

  ContractorBidsLoaded copyWith({
    PaginationModel<BidModel>? bids,
    bool? hasReachedMax,
    String? statusFilter,
    String? searchQuery,
  }) {
    return ContractorBidsLoaded(
      bids: bids ?? this.bids,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Project bids states (for clients)
final class ProjectBidsLoaded extends BidsState {
  final int projectId;
  final PaginationModel<BidModel> bids;
  final bool hasReachedMax;

  const ProjectBidsLoaded({
    required this.projectId,
    required this.bids,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [projectId, bids, hasReachedMax];

  ProjectBidsLoaded copyWith({
    int? projectId,
    PaginationModel<BidModel>? bids,
    bool? hasReachedMax,
  }) {
    return ProjectBidsLoaded(
      projectId: projectId ?? this.projectId,
      bids: bids ?? this.bids,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

// Single bid states
final class BidLoaded extends BidsState {
  final BidModel bid;

  const BidLoaded({required this.bid});

  @override
  List<Object> get props => [bid];
}

final class BidCreated extends BidsState {
  final BidModel bid;

  const BidCreated({required this.bid});

  @override
  List<Object> get props => [bid];
}

final class BidUpdated extends BidsState {
  final BidModel bid;

  const BidUpdated({required this.bid});

  @override
  List<Object> get props => [bid];
}

final class BidDeleted extends BidsState {
  final int projectId;
  final int bidId;

  const BidDeleted({
    required this.projectId,
    required this.bidId,
  });

  @override
  List<Object> get props => [projectId, bidId];
}

final class BidsError extends BidsState {
  final String message;

  const BidsError({required this.message});

  @override
  List<Object> get props => [message];
}
