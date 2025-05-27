part of 'portfolio_bloc.dart';

sealed class PortfolioState extends Equatable {
  const PortfolioState();
  
  @override
  List<Object?> get props => [];
}

final class PortfolioInitial extends PortfolioState {}

final class PortfolioLoading extends PortfolioState {}

final class PortfolioLoaded extends PortfolioState {
  final PaginationModel<PortfolioModel> portfolio;
  final bool hasReachedMax;

  const PortfolioLoaded({
    required this.portfolio,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [portfolio, hasReachedMax];

  PortfolioLoaded copyWith({
    PaginationModel<PortfolioModel>? portfolio,
    bool? hasReachedMax,
  }) {
    return PortfolioLoaded(
      portfolio: portfolio ?? this.portfolio,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

final class ContractorPortfolioLoaded extends PortfolioState {
  final PaginationModel<PortfolioModel> portfolio;
  final int contractorId;
  final bool hasReachedMax;

  const ContractorPortfolioLoaded({
    required this.portfolio,
    required this.contractorId,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [portfolio, contractorId, hasReachedMax];
}

final class PortfolioCreated extends PortfolioState {
  final PortfolioModel portfolio;

  const PortfolioCreated({required this.portfolio});

  @override
  List<Object> get props => [portfolio];
}

final class PortfolioUpdated extends PortfolioState {
  final PortfolioModel portfolio;

  const PortfolioUpdated({required this.portfolio});

  @override
  List<Object> get props => [portfolio];
}

final class PortfolioDeleted extends PortfolioState {
  final int portfolioId;

  const PortfolioDeleted({required this.portfolioId});

  @override
  List<Object> get props => [portfolioId];
}

final class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError({required this.message});

  @override
  List<Object> get props => [message];
}