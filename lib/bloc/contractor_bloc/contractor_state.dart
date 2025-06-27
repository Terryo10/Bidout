part of 'contractor_bloc.dart';

abstract class ContractorState extends Equatable {
  const ContractorState();

  @override
  List<Object?> get props => [];
}

class ContractorInitial extends ContractorState {}

class ContractorLoading extends ContractorState {}

class ContractorLoaded extends ContractorState {
  final PaginationModel<ContractorModel> contractors;
  final bool hasReachedMax;
  final ContractorFilters currentFilters;

  const ContractorLoaded({
    required this.contractors,
    required this.hasReachedMax,
    required this.currentFilters,
  });

  @override
  List<Object?> get props => [contractors, hasReachedMax, currentFilters];

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

class ContractorError extends ContractorState {
  final String message;

  const ContractorError({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

class ContractorSingleLoading extends ContractorState {}

class ContractorSingleLoaded extends ContractorState {
  final ContractorModel contractor;
  final PaginationModel<PortfolioModel>? portfolio;
  final List<ContractorReviewModel>? reviews;

  const ContractorSingleLoaded({
    required this.contractor,
    this.portfolio,
    this.reviews,
  });

  @override
  List<Object?> get props => [contractor, portfolio, reviews];

  ContractorSingleLoaded copyWith({
    ContractorModel? contractor,
    PaginationModel<PortfolioModel>? portfolio,
    List<ContractorReviewModel>? reviews,
  }) {
    return ContractorSingleLoaded(
      contractor: contractor ?? this.contractor,
      portfolio: portfolio ?? this.portfolio,
      reviews: reviews ?? this.reviews,
    );
  }
}
