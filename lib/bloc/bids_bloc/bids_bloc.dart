import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/bids/bid_model.dart';
import '../../models/pagination/pagination_model.dart';
import '../../repositories/bids_repo/bids_repository.dart';

part 'bids_event.dart';
part 'bids_state.dart';

class BidsBloc extends Bloc<BidsEvent, BidsState> {
  final BidsRepository bidsRepository;

  BidsBloc({required this.bidsRepository}) : super(BidsInitial()) {
    on<ContractorBidsLoadRequested>(_onContractorBidsLoadRequested);
    on<ContractorBidsLoadMoreRequested>(_onContractorBidsLoadMoreRequested);
    on<ContractorBidsRefreshRequested>(_onContractorBidsRefreshRequested);
    on<ProjectBidsLoadRequested>(_onProjectBidsLoadRequested);
    on<ProjectBidsLoadMoreRequested>(_onProjectBidsLoadMoreRequested);
    on<ProjectBidsRefreshRequested>(_onProjectBidsRefreshRequested);
    on<BidCreateRequested>(_onBidCreateRequested);
    on<BidUpdateRequested>(_onBidUpdateRequested);
    on<BidDeleteRequested>(_onBidDeleteRequested);
    on<BidLoadRequested>(_onBidLoadRequested);
    on<BidsFilterChanged>(_onBidsFilterChanged);
  }

  Future<void> _onContractorBidsLoadRequested(
    ContractorBidsLoadRequested event,
    Emitter<BidsState> emit,
  ) async {
    emit(BidsLoading());

    try {
      final paginatedBids = await bidsRepository.getContractorBids(
        page: event.page,
        perPage: event.perPage,
        status: event.status,
        search: event.search,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );

      emit(ContractorBidsLoaded(
        bids: paginatedBids,
        hasReachedMax: !paginatedBids.hasNextPage,
        statusFilter: event.status,
        searchQuery: event.search,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(BidsError(message: e.firstError));
      } else {
        emit(
            const BidsError(message: 'Failed to load bids. Please try again.'));
      }
    }
  }

  Future<void> _onContractorBidsLoadMoreRequested(
    ContractorBidsLoadMoreRequested event,
    Emitter<BidsState> emit,
  ) async {
    if (state is ContractorBidsLoaded) {
      final currentState = state as ContractorBidsLoaded;
      if (currentState.hasReachedMax) return;

      emit(BidsLoadingMore());

      try {
        final nextPage = currentState.bids.currentPage + 1;
        final paginatedBids = await bidsRepository.getContractorBids(
          page: nextPage,
          status: currentState.statusFilter,
          search: currentState.searchQuery,
        );

        // Combine existing and new data
        final updatedBids = currentState.bids.copyWith(
          data: [...currentState.bids.data, ...paginatedBids.data],
          currentPage: paginatedBids.currentPage,
          hasNextPage: paginatedBids.hasNextPage,
        );

        emit(ContractorBidsLoaded(
          bids: updatedBids,
          hasReachedMax: !paginatedBids.hasNextPage,
          statusFilter: currentState.statusFilter,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(currentState); // Revert to previous state on error
        if (e is ApiErrorModel) {
          emit(BidsError(message: e.firstError));
        } else {
          emit(const BidsError(
              message: 'Failed to load more bids. Please try again.'));
        }
      }
    }
  }

  Future<void> _onContractorBidsRefreshRequested(
    ContractorBidsRefreshRequested event,
    Emitter<BidsState> emit,
  ) async {
    if (state is ContractorBidsLoaded) {
      final currentState = state as ContractorBidsLoaded;
      emit(BidsRefreshing());

      try {
        final paginatedBids = await bidsRepository.getContractorBids(
          page: 1,
          status: currentState.statusFilter,
          search: currentState.searchQuery,
        );

        emit(ContractorBidsLoaded(
          bids: paginatedBids,
          hasReachedMax: !paginatedBids.hasNextPage,
          statusFilter: currentState.statusFilter,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(currentState); // Revert to previous state on error
        if (e is ApiErrorModel) {
          emit(BidsError(message: e.firstError));
        } else {
          emit(const BidsError(
              message: 'Failed to refresh bids. Please try again.'));
        }
      }
    }
  }

  Future<void> _onProjectBidsLoadRequested(
    ProjectBidsLoadRequested event,
    Emitter<BidsState> emit,
  ) async {
    emit(BidsLoading());

    try {
      final paginatedBids = await bidsRepository.getProjectBids(
        event.projectId,
        page: event.page,
        perPage: event.perPage,
      );

      emit(ProjectBidsLoaded(
        projectId: event.projectId,
        bids: paginatedBids,
        hasReachedMax: !paginatedBids.hasNextPage,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(BidsError(message: e.firstError));
      } else {
        emit(const BidsError(
            message: 'Failed to load project bids. Please try again.'));
      }
    }
  }

  Future<void> _onProjectBidsLoadMoreRequested(
    ProjectBidsLoadMoreRequested event,
    Emitter<BidsState> emit,
  ) async {
    if (state is ProjectBidsLoaded) {
      final currentState = state as ProjectBidsLoaded;
      if (currentState.hasReachedMax ||
          currentState.projectId != event.projectId) return;

      emit(BidsLoadingMore());

      try {
        final nextPage = currentState.bids.currentPage + 1;
        final paginatedBids = await bidsRepository.getProjectBids(
          event.projectId,
          page: nextPage,
        );

        // Combine existing and new data
        final updatedBids = currentState.bids.copyWith(
          data: [...currentState.bids.data, ...paginatedBids.data],
          currentPage: paginatedBids.currentPage,
          hasNextPage: paginatedBids.hasNextPage,
        );

        emit(ProjectBidsLoaded(
          projectId: event.projectId,
          bids: updatedBids,
          hasReachedMax: !paginatedBids.hasNextPage,
        ));
      } catch (e) {
        emit(currentState); // Revert to previous state on error
        if (e is ApiErrorModel) {
          emit(BidsError(message: e.firstError));
        } else {
          emit(const BidsError(
              message: 'Failed to load more bids. Please try again.'));
        }
      }
    }
  }

  Future<void> _onProjectBidsRefreshRequested(
    ProjectBidsRefreshRequested event,
    Emitter<BidsState> emit,
  ) async {
    if (state is ProjectBidsLoaded) {
      final currentState = state as ProjectBidsLoaded;
      if (currentState.projectId != event.projectId) return;

      emit(BidsRefreshing());

      try {
        final paginatedBids = await bidsRepository.getProjectBids(
          event.projectId,
          page: 1,
        );

        emit(ProjectBidsLoaded(
          projectId: event.projectId,
          bids: paginatedBids,
          hasReachedMax: !paginatedBids.hasNextPage,
        ));
      } catch (e) {
        emit(currentState); // Revert to previous state on error
        if (e is ApiErrorModel) {
          emit(BidsError(message: e.firstError));
        } else {
          emit(const BidsError(
              message: 'Failed to refresh bids. Please try again.'));
        }
      }
    }
  }

  Future<void> _onBidCreateRequested(
    BidCreateRequested event,
    Emitter<BidsState> emit,
  ) async {
    emit(BidsLoading());

    try {
      final bid = await bidsRepository.createBid(event.bidRequest);
      emit(BidCreated(bid: bid));

      // Refresh contractor bids if we're in that state
      if (state is ContractorBidsLoaded) {
        add(const ContractorBidsRefreshRequested());
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(BidsError(message: e.firstError));
      } else {
        emit(const BidsError(
            message: 'Failed to create bid. Please try again.'));
      }
    }
  }

  Future<void> _onBidUpdateRequested(
    BidUpdateRequested event,
    Emitter<BidsState> emit,
  ) async {
    emit(BidsLoading());

    try {
      final bid = await bidsRepository.updateBid(
        event.projectId,
        event.bidId,
        event.bidRequest,
      );
      emit(BidUpdated(bid: bid));

      // Refresh contractor bids if we're in that state
      if (state is ContractorBidsLoaded) {
        add(const ContractorBidsRefreshRequested());
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(BidsError(message: e.firstError));
      } else {
        emit(const BidsError(
            message: 'Failed to update bid. Please try again.'));
      }
    }
  }

  Future<void> _onBidDeleteRequested(
    BidDeleteRequested event,
    Emitter<BidsState> emit,
  ) async {
    emit(BidsLoading());

    try {
      await bidsRepository.deleteBid(event.projectId, event.bidId);
      emit(BidDeleted(projectId: event.projectId, bidId: event.bidId));

      // Refresh contractor bids if we're in that state
      if (state is ContractorBidsLoaded) {
        add(const ContractorBidsRefreshRequested());
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(BidsError(message: e.firstError));
      } else {
        emit(const BidsError(
            message: 'Failed to delete bid. Please try again.'));
      }
    }
  }

  Future<void> _onBidLoadRequested(
    BidLoadRequested event,
    Emitter<BidsState> emit,
  ) async {
    emit(BidsLoading());

    try {
      final bid = await bidsRepository.getBid(event.projectId, event.bidId);
      if (bid != null) {
        emit(BidLoaded(bid: bid));
      } else {
        emit(const BidsError(message: 'Bid not found'));
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(BidsError(message: e.firstError));
      } else {
        emit(const BidsError(message: 'Failed to load bid. Please try again.'));
      }
    }
  }

  Future<void> _onBidsFilterChanged(
    BidsFilterChanged event,
    Emitter<BidsState> emit,
  ) async {
    if (state is ContractorBidsLoaded) {
      // Reload with new filters
      add(ContractorBidsLoadRequested(
        status: event.status,
        search: event.search,
      ));
    }
  }
}
