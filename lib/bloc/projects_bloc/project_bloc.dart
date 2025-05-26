import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/projects/project_model.dart';
import '../../models/projects/project_request_model.dart' as request;
import '../../repositories/projects_repo/projects_repository.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository projectRepository;

  ProjectBloc({required this.projectRepository}) : super(ProjectInitial()) {
    on<ProjectLoadRequested>(_onProjectLoadRequested);
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
      final project = await projectRepository.getProjects();
      emit(ProjectLoaded(project: project));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ProjectError(message: e.firstError));
      } else {
        emit(const ProjectError(
            message: 'Failed to load Project. Please try again.'));
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
