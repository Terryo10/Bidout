import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/pagination/pagination_model.dart';
import '../../models/projects/project_model.dart';
import '../../repositories/contractor_projects_repo/contractor_projects_repository.dart';

part 'contractor_projects_event.dart';
part 'contractor_projects_state.dart';

class ContractorProjectsBloc
    extends Bloc<ContractorProjectsEvent, ContractorProjectsState> {
  final ContractorProjectsRepository contractorProjectsRepository;

  // Store the last loaded projects state to restore it later
  ContractorProjectsLoaded? _lastLoadedState;

  ContractorProjectsBloc({required this.contractorProjectsRepository})
      : super(ContractorProjectsInitial()) {
    on<ContractorProjectsLoadRequested>(_onContractorProjectsLoadRequested);
    on<ContractorProjectsLoadMoreRequested>(
        _onContractorProjectsLoadMoreRequested);
    on<ContractorProjectsRefreshRequested>(
        _onContractorProjectsRefreshRequested);
    on<ContractorProjectsSearchRequested>(_onContractorProjectsSearchRequested);
    on<ContractorProjectsSingleLoadRequested>(
        _onContractorProjectsSingleLoadRequested);
  }

  Future<void> _onContractorProjectsLoadRequested(
    ContractorProjectsLoadRequested event,
    Emitter<ContractorProjectsState> emit,
  ) async {
    emit(ContractorProjectsLoading());

    try {
      final paginatedProjects =
          await contractorProjectsRepository.getAvailableProjects(
        page: event.page,
        perPage: event.perPage,
        search: event.search,
        status: event.status,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      final newState = ContractorProjectsLoaded(
        projects: paginatedProjects,
        hasReachedMax: !paginatedProjects.hasNextPage,
      );

      // Store this state for potential restoration later
      _lastLoadedState = newState;
      emit(newState);
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorProjectsError(message: e.firstError));
      } else {
        emit(const ContractorProjectsError(
            message: 'Failed to load available projects. Please try again.'));
      }
    }
  }

  Future<void> _onContractorProjectsLoadMoreRequested(
    ContractorProjectsLoadMoreRequested event,
    Emitter<ContractorProjectsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ContractorProjectsLoaded &&
        !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.projects.currentPage + 1;
        final paginatedProjects =
            await contractorProjectsRepository.getAvailableProjects(
          page: nextPage,
          perPage: event.perPage,
          search: event.search,
          status: event.status,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
        );

        // Combine existing projects with new ones
        final allProjects = List<ProjectModel>.from(currentState.projects.data)
          ..addAll(paginatedProjects.data);

        final updatedPagination = PaginationModel<ProjectModel>(
          currentPage: paginatedProjects.currentPage,
          data: allProjects,
          firstPageUrl: paginatedProjects.firstPageUrl,
          from: currentState.projects.from,
          lastPage: paginatedProjects.lastPage,
          lastPageUrl: paginatedProjects.lastPageUrl,
          links: paginatedProjects.links,
          nextPageUrl: paginatedProjects.nextPageUrl,
          path: paginatedProjects.path,
          perPage: paginatedProjects.perPage,
          prevPageUrl: paginatedProjects.prevPageUrl,
          to: paginatedProjects.to,
          total: paginatedProjects.total,
        );

        final newState = ContractorProjectsLoaded(
          projects: updatedPagination,
          hasReachedMax: !paginatedProjects.hasNextPage,
        );

        // Update stored state
        _lastLoadedState = newState;
        emit(newState);
      } catch (e) {
        if (e is ApiErrorModel) {
          emit(ContractorProjectsError(message: e.firstError));
        } else {
          emit(const ContractorProjectsError(
              message: 'Failed to load more projects. Please try again.'));
        }
      }
    }
  }

  Future<void> _onContractorProjectsRefreshRequested(
    ContractorProjectsRefreshRequested event,
    Emitter<ContractorProjectsState> emit,
  ) async {
    try {
      final paginatedProjects =
          await contractorProjectsRepository.getAvailableProjects(
        page: 1,
        perPage: event.perPage,
        search: event.search,
        status: event.status,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      final newState = ContractorProjectsLoaded(
        projects: paginatedProjects,
        hasReachedMax: !paginatedProjects.hasNextPage,
      );

      // Update stored state
      _lastLoadedState = newState;
      emit(newState);
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorProjectsError(message: e.firstError));
      } else {
        emit(const ContractorProjectsError(
            message: 'Failed to refresh projects. Please try again.'));
      }
    }
  }

  Future<void> _onContractorProjectsSearchRequested(
    ContractorProjectsSearchRequested event,
    Emitter<ContractorProjectsState> emit,
  ) async {
    emit(ContractorProjectsLoading());

    try {
      final paginatedProjects =
          await contractorProjectsRepository.getAvailableProjects(
        page: 1,
        search: event.query,
        status: event.status,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      final newState = ContractorProjectsLoaded(
        projects: paginatedProjects,
        hasReachedMax: !paginatedProjects.hasNextPage,
      );

      // Update stored state
      _lastLoadedState = newState;
      emit(newState);
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorProjectsError(message: e.firstError));
      } else {
        emit(const ContractorProjectsError(
            message: 'Failed to search projects. Please try again.'));
      }
    }
  }

  Future<void> _onContractorProjectsSingleLoadRequested(
    ContractorProjectsSingleLoadRequested event,
    Emitter<ContractorProjectsState> emit,
  ) async {
    // Don't emit loading state for single project to avoid losing the projects list UI
    // Instead, we'll work with the current state

    try {
      final projectResponse =
          await contractorProjectsRepository.getProject(event.projectId);
      if (projectResponse != null) {
        // Use the stored last loaded state or current state to preserve projects list
        final baseState = _lastLoadedState ??
            (state is ContractorProjectsLoaded
                ? state as ContractorProjectsLoaded
                : null);

        if (baseState != null) {
          // Preserve the existing projects list and add the selected project
          final newState = baseState.copyWith(
            selectedProject: projectResponse.project,
            userHasBid: projectResponse.userHasBid,
          );
          emit(newState);
        } else {
          // If we have no previous state, create a new one (this should rarely happen)
          final newState = ContractorProjectsLoaded(
            projects: PaginationModel.empty(),
            hasReachedMax: true,
            selectedProject: projectResponse.project,
            userHasBid: projectResponse.userHasBid,
          );
          emit(newState);
        }
      } else {
        emit(const ContractorProjectsError(message: 'Project not found'));
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ContractorProjectsError(message: e.firstError));
      } else {
        emit(const ContractorProjectsError(
            message: 'Failed to load project. Please try again.'));
      }
    }
  }
}
