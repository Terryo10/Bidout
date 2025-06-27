// lib/bloc/contractor_bloc/contractor_event.dart
part of 'contractor_bloc.dart';

abstract class ContractorEvent extends Equatable {
  const ContractorEvent();

  @override
  List<Object?> get props => [];
}

class ContractorLoadRequested extends ContractorEvent {
  final int page;
  final int perPage;
  final String? search;
  final List<String>? services;
  final double? minRating;
  final String? location;
  final bool? isFeatured;
  final bool? hasSubscription;

  const ContractorLoadRequested({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.services,
    this.minRating,
    this.location,
    this.isFeatured,
    this.hasSubscription,
  });

  @override
  List<Object?> get props => [
        page,
        perPage,
        search,
        services,
        minRating,
        location,
        isFeatured,
        hasSubscription,
      ];
}

class ContractorLoadMoreRequested extends ContractorEvent {
  final int perPage;

  const ContractorLoadMoreRequested({
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [perPage];
}

class ContractorRefreshRequested extends ContractorEvent {
  final int perPage;

  const ContractorRefreshRequested({
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [perPage];
}

class ContractorSearchRequested extends ContractorEvent {
  final String? query;
  final List<String>? services;
  final double? minRating;
  final String? location;
  final bool? isFeatured;
  final bool? hasSubscription;

  const ContractorSearchRequested({
    this.query,
    this.services,
    this.minRating,
    this.location,
    this.isFeatured,
    this.hasSubscription,
  });

  @override
  List<Object?> get props => [
        query,
        services,
        minRating,
        location,
        isFeatured,
        hasSubscription,
      ];
}

class ContractorSingleLoadRequested extends ContractorEvent {
  final int contractorId;

  const ContractorSingleLoadRequested({
    required this.contractorId,
  });

  @override
  List<Object?> get props => [contractorId];
}

class ContractorFilterChanged extends ContractorEvent {
  final ContractorFilters filters;

  const ContractorFilterChanged({
    required this.filters,
  });

  @override
  List<Object?> get props => [filters];
}

class ContractorFilters extends Equatable {
  final String? search;
  final List<String>? services;
  final double? minRating;
  final String? location;
  final bool? isFeatured;
  final bool? hasSubscription;

  const ContractorFilters({
    this.search,
    this.services,
    this.minRating,
    this.location,
    this.isFeatured,
    this.hasSubscription,
  });

  @override
  List<Object?> get props => [
        search,
        services,
        minRating,
        location,
        isFeatured,
        hasSubscription,
      ];
}

class ContractorPortfolioLoadRequested extends ContractorEvent {
  final int contractorId;
  final int page;
  final int perPage;

  const ContractorPortfolioLoadRequested({
    required this.contractorId,
    this.page = 1,
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [contractorId, page, perPage];
}

class ContractorReviewsLoadRequested extends ContractorEvent {
  final int contractorId;

  const ContractorReviewsLoadRequested({
    required this.contractorId,
  });

  @override
  List<Object?> get props => [contractorId];
}
