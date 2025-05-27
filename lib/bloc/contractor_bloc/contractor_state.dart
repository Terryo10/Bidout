part of 'contractor_bloc.dart';

sealed class ContractorState extends Equatable {
  const ContractorState();
  
  @override
  List<Object?> get props => [];
}

final class ContractorInitial extends ContractorState {}

final class ContractorLoading extends ContractorState {}

final class ContractorSingleLoading extends ContractorState {}

final class ContractorLoaded extends ContractorState {
  final PaginationModel<ContractorModel> contractors;
  final bool hasReachedMax;
  final ContractorFilters currentFilters;

  const ContractorLoaded({
    required this.contractors,
    required this.hasReachedMax,
    required this.currentFilters,
  });

  @override
  List<Object> get props => [contractors, hasReachedMax, currentFilters];

  ContractorLoaded copyWith({
    PaginationModel<ContractorModel>? contractors,
    bool? hasReachedMax,
    ContractorFilters? currentFilters,
  }) {
    return ContractorLoaded(
      contractors: contractors ?? this.contractors,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentFilters: currentFilters ?? this.currentFilters,
    );
  }
}

final class ContractorSingleLoaded extends ContractorState {
  final ContractorModel contractor;

  const ContractorSingleLoaded({required this.contractor});

  @override
  List<Object> get props => [contractor];
}

final class ContractorError extends ContractorState {
  final String message;

  const ContractorError({required this.message});

  @override
  List<Object> get props => [message];
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
    search, services, minRating, location, isFeatured, hasSubscription
  ];

  ContractorFilters copyWith({
    String? search,
    List<String>? services,
    double? minRating,
    String? location,
    bool? isFeatured,
    bool? hasSubscription,
  }) {
    return ContractorFilters(
      search: search ?? this.search,
      services: services ?? this.services,
      minRating: minRating ?? this.minRating,
      location: location ?? this.location,
      isFeatured: isFeatured ?? this.isFeatured,
      hasSubscription: hasSubscription ?? this.hasSubscription,
    );
  }

  bool get hasActiveFilters {
    return search?.isNotEmpty == true ||
           services?.isNotEmpty == true ||
           minRating != null ||
           location?.isNotEmpty == true ||
           isFeatured == true ||
           hasSubscription == true;
  }
}