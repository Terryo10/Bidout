import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/pagination/pagination_model.dart';
import '../../models/projects/project_model.dart';
import '../../models/projects/project_detail_response_model.dart';
import '../../models/projects/project_request_model.dart' as request;
import '../../repositories/projects_repo/projects_repository.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository projectRepository;

  ProjectBloc({required this.projectRepository}) : super(ProjectInitial()) {
    on<ProjectLoadRequested>(_onProjectLoadRequested);
    on<ProjectLoadMoreRequested>(_onProjectLoadMoreRequested);
    on<ProjectRefreshRequested>(_onProjectRefreshRequested);
    on<ProjectSearchRequested>(_onProjectSearchRequested);
    on<ProjectSingleLoadRequested>(_onProjectSingleLoadRequested);
    on<ProjectCreateRequested>(_onProjectCreateRequested);
    on<ProjectUpdateRequested>(_onProjectUpdateRequested);
    on<ProjectDeleteRequested>(_onProjectDeleteRequested);
  }

  Future<void> _onProjectLoadRequested(
    ProjectLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    try {
      final paginatedProjects = await projectRepository.getProjects(
        page: event.page,
        perPage: event.perPage,
        search: event.search,
        status: event.status,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      emit(ProjectLoaded(
        projects: paginatedProjects,
        hasReachedMax: !paginatedProjects.hasNextPage,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ProjectError(message: e.firstError));
      } else {
        emit(const ProjectError(
            message: 'Failed to load projects. Please try again.'));
      }
    }
  }

  Future<void> _onProjectLoadMoreRequested(
    ProjectLoadMoreRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.projects.currentPage + 1;
        final paginatedProjects = await projectRepository.getProjects(
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

        emit(ProjectLoaded(
          projects: updatedPagination,
          hasReachedMax: !paginatedProjects.hasNextPage,
        ));
      } catch (e) {
        if (e is ApiErrorModel) {
          emit(ProjectError(message: e.firstError));
        } else {
          emit(const ProjectError(
              message: 'Failed to load more projects. Please try again.'));
        }
      }
    }
  }

  Future<void> _onProjectRefreshRequested(
    ProjectRefreshRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final paginatedProjects = await projectRepository.getProjects(
        page: 1,
        perPage: event.perPage,
        search: event.search,
        status: event.status,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      emit(ProjectLoaded(
        projects: paginatedProjects,
        hasReachedMax: !paginatedProjects.hasNextPage,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ProjectError(message: e.firstError));
      } else {
        emit(const ProjectError(
            message: 'Failed to refresh projects. Please try again.'));
      }
    }
  }

  Future<void> _onProjectSearchRequested(
    ProjectSearchRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    try {
      final paginatedProjects = await projectRepository.getProjects(
        page: 1,
        search: event.query,
        status: event.status,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      );
      emit(ProjectLoaded(
        projects: paginatedProjects,
        hasReachedMax: !paginatedProjects.hasNextPage,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ProjectError(message: e.firstError));
      } else {
        emit(const ProjectError(
            message: 'Failed to search projects. Please try again.'));
      }
    }
  }

  Future<void> _onProjectSingleLoadRequested(
    ProjectSingleLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectSingleLoading());

    try {
      final projectResponse =
          await projectRepository.getProject(event.projectId);
      if (projectResponse != null) {
        emit(ProjectSingleLoaded(
          project: projectResponse.project,
          userHasBid: projectResponse.userHasBid,
        ));
      } else {
        emit(const ProjectError(message: 'Project not found'));
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ProjectError(message: e.firstError));
      } else {
        emit(const ProjectError(
            message: 'Failed to load project. Please try again.'));
      }
    }
  }

  Future<void> _onProjectCreateRequested(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    try {
      final projectRequest = request.ProjectRequestModel(
        title: event.title,
        description: event.description,
        additionalRequirements: event.additionalRequirements,
        budget: event.budget,
        frequency: event.frequency,
        keyFactor: event.keyFactor,
        startDate: event.startDate,
        endDate: event.endDate,
        street: event.street,
        city: event.city,
        state: event.state,
        zipCode: event.zipCode,
        serviceId: event.serviceId,
        images: event.imagePaths,
        isDrafted: event.isDrafted,
      );

      final project = await projectRepository.createProject(projectRequest);
      emit(ProjectCreated(project: project));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ProjectError(message: e.firstError));
      } else {
        emit(const ProjectError(
            message: 'Failed to create project. Please try again.'));
      }
    }
  }

  Future<void> _onProjectUpdateRequested(
    ProjectUpdateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    try {
      final projectRequest = request.ProjectRequestModel(
        title: event.title,
        description: event.description,
        additionalRequirements: event.additionalRequirements,
        budget: event.budget,
        frequency: event.frequency,
        keyFactor: event.keyFactor,
        startDate: event.startDate,
        endDate: event.endDate,
        street: event.street,
        city: event.city,
        state: event.state,
        zipCode: event.zipCode,
        serviceId: event.serviceId,
        images: event.imagePaths,
        isDrafted: event.isDrafted,
      );

      final project = await projectRepository.updateProject(
          event.projectId, projectRequest);
      emit(ProjectUpdated(project: project));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ProjectError(message: e.firstError));
      } else {
        emit(const ProjectError(
            message: 'Failed to update project. Please try again.'));
      }
    }
  }

  Future<void> _onProjectDeleteRequested(
    ProjectDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    try {
      await projectRepository.deleteProject(event.projectId);
      emit(ProjectDeleted(projectId: event.projectId));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ProjectError(message: e.firstError));
      } else {
        emit(const ProjectError(
            message: 'Failed to delete project. Please try again.'));
      }
    }
  }
}
