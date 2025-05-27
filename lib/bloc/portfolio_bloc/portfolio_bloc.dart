import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/contractor/portfolio_model.dart';
import '../../models/pagination/pagination_model.dart';
import '../../repositories/contractor_repo/contractor_repo.dart';

part 'portfolio_event.dart';
part 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final ContractorRepository contractorRepository;

  PortfolioBloc({required this.contractorRepository}) : super(PortfolioInitial()) {
    on<PortfolioLoadRequested>(_onPortfolioLoadRequested);
    on<PortfolioLoadMoreRequested>(_onPortfolioLoadMoreRequested);
    on<PortfolioRefreshRequested>(_onPortfolioRefreshRequested);
    on<PortfolioCreateRequested>(_onPortfolioCreateRequested);
    on<PortfolioUpdateRequested>(_onPortfolioUpdateRequested);
    on<PortfolioDeleteRequested>(_onPortfolioDeleteRequested);
    on<ContractorPortfolioLoadRequested>(_onContractorPortfolioLoadRequested);
  }

  Future<void> _onPortfolioLoadRequested(
    PortfolioLoadRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(PortfolioLoading());

    try {
      final paginatedPortfolio = await contractorRepository.getMyPortfolio(
        page: event.page,
        perPage: event.perPage,
      );
      
      emit(PortfolioLoaded(
        portfolio: paginatedPortfolio,
        hasReachedMax: !paginatedPortfolio.hasNextPage,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(PortfolioError(message: e.firstError));
      } else {
        emit(const PortfolioError(
            message: 'Failed to load portfolio. Please try again.'));
      }
    }
  }

  Future<void> _onPortfolioLoadMoreRequested(
    PortfolioLoadMoreRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    final currentState = state;
    if (currentState is PortfolioLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.portfolio.currentPage + 1;
        final paginatedPortfolio = await contractorRepository.getMyPortfolio(
          page: nextPage,
          perPage: event.perPage,
        );

        final allPortfolio = List<PortfolioModel>.from(currentState.portfolio.data)
          ..addAll(paginatedPortfolio.data);

        final updatedPagination = PaginationModel<PortfolioModel>(
          currentPage: paginatedPortfolio.currentPage,
          data: allPortfolio,
          firstPageUrl: paginatedPortfolio.firstPageUrl,
          from: currentState.portfolio.from,
          lastPage: paginatedPortfolio.lastPage,
          lastPageUrl: paginatedPortfolio.lastPageUrl,
          links: paginatedPortfolio.links,
          nextPageUrl: paginatedPortfolio.nextPageUrl,
          path: paginatedPortfolio.path,
          perPage: paginatedPortfolio.perPage,
          prevPageUrl: paginatedPortfolio.prevPageUrl,
          to: paginatedPortfolio.to,
          total: paginatedPortfolio.total,
        );

        emit(PortfolioLoaded(
          portfolio: updatedPagination,
          hasReachedMax: !paginatedPortfolio.hasNextPage,
        ));
      } catch (e) {
        if (e is ApiErrorModel) {
          emit(PortfolioError(message: e.firstError));
        } else {
          emit(const PortfolioError(
              message: 'Failed to load more portfolio items. Please try again.'));
        }
      }
    }
  }

  Future<void> _onPortfolioRefreshRequested(
    PortfolioRefreshRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    try {
      final paginatedPortfolio = await contractorRepository.getMyPortfolio(
        page: 1,
        perPage: event.perPage,
      );
      
      emit(PortfolioLoaded(
        portfolio: paginatedPortfolio,
        hasReachedMax: !paginatedPortfolio.hasNextPage,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(PortfolioError(message: e.firstError));
      } else {
        emit(const PortfolioError(
            message: 'Failed to refresh portfolio. Please try again.'));
      }
    }
  }

  Future<void> _onPortfolioCreateRequested(
    PortfolioCreateRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(PortfolioLoading());

    try {
      final portfolio = await contractorRepository.createPortfolio(
        title: event.title,
        description: event.description,
        projectType: event.projectType,
        completionDate: event.completionDate,
        projectValue: event.projectValue,
        clientName: event.clientName,
        clientTestimonial: event.clientTestimonial,
        tags: event.tags,
        isFeatured: event.isFeatured,
        imagePaths: event.imagePaths,
      );
      
      emit(PortfolioCreated(portfolio: portfolio));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(PortfolioError(message: e.firstError));
      } else {
        emit(const PortfolioError(
            message: 'Failed to create portfolio item. Please try again.'));
      }
    }
  }

  Future<void> _onPortfolioUpdateRequested(
    PortfolioUpdateRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(PortfolioLoading());

    try {
      final portfolio = await contractorRepository.updatePortfolio(
        event.portfolioId,
        title: event.title,
        description: event.description,
        projectType: event.projectType,
        completionDate: event.completionDate,
        projectValue: event.projectValue,
        clientName: event.clientName,
        clientTestimonial: event.clientTestimonial,
        tags: event.tags,
        isFeatured: event.isFeatured,
        imagePaths: event.imagePaths,
      );
      
      emit(PortfolioUpdated(portfolio: portfolio));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(PortfolioError(message: e.firstError));
      } else {
        emit(const PortfolioError(
            message: 'Failed to update portfolio item. Please try again.'));
      }
    }
  }

  Future<void> _onPortfolioDeleteRequested(
    PortfolioDeleteRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(PortfolioLoading());

    try {
      await contractorRepository.deletePortfolio(event.portfolioId);
      emit(PortfolioDeleted(portfolioId: event.portfolioId));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(PortfolioError(message: e.firstError));
      } else {
        emit(const PortfolioError(
            message: 'Failed to delete portfolio item. Please try again.'));
      }
    }
  }

  Future<void> _onContractorPortfolioLoadRequested(
    ContractorPortfolioLoadRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(PortfolioLoading());

    try {
      final paginatedPortfolio = await contractorRepository.getContractorPortfolio(
        event.contractorId,
        page: event.page,
        perPage: event.perPage,
      );
      
      emit(ContractorPortfolioLoaded(
        portfolio: paginatedPortfolio,
        contractorId: event.contractorId,
        hasReachedMax: !paginatedPortfolio.hasNextPage,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(PortfolioError(message: e.firstError));
      } else {
        emit(const PortfolioError(
            message: 'Failed to load contractor portfolio. Please try again.'));
      }
    }
  }
}