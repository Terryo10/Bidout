// lib/bloc/contractor_bloc/contractor_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/contractor/contractor_model.dart';
import '../../models/pagination/pagination_model.dart';
import '../../repositories/contractor_repo/contractor_repo.dart';

part 'contractor_event.dart';
part 'contractor_state.dart';

class ContractorBloc extends Bloc<ContractorEvent, ContractorState> {
  final ContractorRepository contractorRepository;

  ContractorBloc({required this.contractorRepository}) : super(ContractorInitial()) {
    on<ContractorLoadRequested>(_onContractorLoadRequested);
    on<ContractorLoadMoreRequested>(_onContractorLoadMoreRequested);
    on<ContractorRefreshRequested>(_onContractorRefreshRequested);
    on<ContractorSearchRequested>(_onContractorSearchRequested);
    on<ContractorSingleLoadRequested>(_onContractorSingleLoadRequested);
    on<ContractorFilterChanged>(_onContractorFilterChanged);
  }

  Future<void> _onContractorLoadRequested(
    ContractorLoadRequested event,
    Emitter<ContractorState> emit,
  ) async {
    emit(ContractorLoading());

    try {
      final paginatedContractors = await contractorRepository.getContractors(
        page: event.page,
        perPage: event.perPage,
        search: event.search,
        services: event.services,
        minRating: event.minRating,
        location: event.location,
        isFeatured: event.isFeatured,
        hasSubscription: event.hasSubscription,
      );
      
      emit(ContractorLoaded(
        contractors: paginatedContractors,
        hasReachedMax: !paginatedContractors.hasNextPage,
        currentFilters: ContractorFilters(
          search: event.search,
          services: event.services,
          minRating: event.minRating,
          location: event.location,
          isFeatured: event.isFeatured,
          hasSubscription: event.hasSubscription,
        ),
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorError(message: e.firstError));
      } else {
        emit(const ContractorError(
            message: 'Failed to load contractors. Please try again.'));
      }
    }
  }

  Future<void> _onContractorLoadMoreRequested(
    ContractorLoadMoreRequested event,
    Emitter<ContractorState> emit,
  ) async {
    final currentState = state;
    if (currentState is ContractorLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.contractors.currentPage + 1;
        final paginatedContractors = await contractorRepository.getContractors(
          page: nextPage,
          perPage: event.perPage,
          search: currentState.currentFilters.search,
          services: currentState.currentFilters.services,
          minRating: currentState.currentFilters.minRating,
          location: currentState.currentFilters.location,
          isFeatured: currentState.currentFilters.isFeatured,
          hasSubscription: currentState.currentFilters.hasSubscription,
        );

        final allContractors = List<ContractorModel>.from(currentState.contractors.data)
          ..addAll(paginatedContractors.data);

        final updatedPagination = PaginationModel<ContractorModel>(
          currentPage: paginatedContractors.currentPage,
          data: allContractors,
          firstPageUrl: paginatedContractors.firstPageUrl,
          from: currentState.contractors.from,
          lastPage: paginatedContractors.lastPage,
          lastPageUrl: paginatedContractors.lastPageUrl,
          links: paginatedContractors.links,
          nextPageUrl: paginatedContractors.nextPageUrl,
          path: paginatedContractors.path,
          perPage: paginatedContractors.perPage,
          prevPageUrl: paginatedContractors.prevPageUrl,
          to: paginatedContractors.to,
          total: paginatedContractors.total,
        );

        emit(ContractorLoaded(
          contractors: updatedPagination,
          hasReachedMax: !paginatedContractors.hasNextPage,
          currentFilters: currentState.currentFilters,
        ));
      } catch (e) {
        if (e is ApiErrorModel) {
          emit(ContractorError(message: e.firstError));
        } else {
          emit(const ContractorError(
              message: 'Failed to load more contractors. Please try again.'));
        }
      }
    }
  }

  Future<void> _onContractorRefreshRequested(
    ContractorRefreshRequested event,
    Emitter<ContractorState> emit,
  ) async {
    final currentState = state;
    ContractorFilters filters = const ContractorFilters();
    
    if (currentState is ContractorLoaded) {
      filters = currentState.currentFilters;
    }

    try {
      final paginatedContractors = await contractorRepository.getContractors(
        page: 1,
        perPage: event.perPage,
        search: filters.search,
        services: filters.services,
        minRating: filters.minRating,
        location: filters.location,
        isFeatured: filters.isFeatured,
        hasSubscription: filters.hasSubscription,
      );
      
      emit(ContractorLoaded(
        contractors: paginatedContractors,
        hasReachedMax: !paginatedContractors.hasNextPage,
        currentFilters: filters,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorError(message: e.firstError));
      } else {
        emit(const ContractorError(
            message: 'Failed to refresh contractors. Please try again.'));
      }
    }
  }

  Future<void> _onContractorSearchRequested(
    ContractorSearchRequested event,
    Emitter<ContractorState> emit,
  ) async {
    emit(ContractorLoading());

    try {
      final paginatedContractors = await contractorRepository.getContractors(
        page: 1,
        search: event.query,
        services: event.services,
        minRating: event.minRating,
        location: event.location,
        isFeatured: event.isFeatured,
        hasSubscription: event.hasSubscription,
      );
      
      emit(ContractorLoaded(
        contractors: paginatedContractors,
        hasReachedMax: !paginatedContractors.hasNextPage,
        currentFilters: ContractorFilters(
          search: event.query,
          services: event.services,
          minRating: event.minRating,
          location: event.location,
          isFeatured: event.isFeatured,
          hasSubscription: event.hasSubscription,
        ),
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorError(message: e.firstError));
      } else {
        emit(const ContractorError(
            message: 'Failed to search contractors. Please try again.'));
      }
    }
  }

  Future<void> _onContractorSingleLoadRequested(
    ContractorSingleLoadRequested event,
    Emitter<ContractorState> emit,
  ) async {
    emit(ContractorSingleLoading());

    try {
      final contractor = await contractorRepository.getContractor(event.contractorId);
      if (contractor != null) {
        emit(ContractorSingleLoaded(contractor: contractor));
      } else {
        emit(const ContractorError(message: 'Contractor not found'));
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorError(message: e.firstError));
      } else {
        emit(const ContractorError(
            message: 'Failed to load contractor. Please try again.'));
      }
    }
  }

  Future<void> _onContractorFilterChanged(
    ContractorFilterChanged event,
    Emitter<ContractorState> emit,
  ) async {
    emit(ContractorLoading());

    try {
      final paginatedContractors = await contractorRepository.getContractors(
        page: 1,
        search: event.filters.search,
        services: event.filters.services,
        minRating: event.filters.minRating,
        location: event.filters.location,
        isFeatured: event.filters.isFeatured,
        hasSubscription: event.filters.hasSubscription,
      );
      
      emit(ContractorLoaded(
        contractors: paginatedContractors,
        hasReachedMax: !paginatedContractors.hasNextPage,
        currentFilters: event.filters,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorError(message: e.firstError));
      } else {
        emit(const ContractorError(
            message: 'Failed to apply filters. Please try again.'));
      }
    }
  }
}