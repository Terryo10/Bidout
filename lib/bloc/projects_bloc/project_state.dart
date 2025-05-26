
part of 'project_bloc.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();
  
  @override
  List<Object?> get props => [];
}

final class ProjectInitial extends ProjectState {}

final class ProjectLoading extends ProjectState {}

final class ProjectLoaded extends ProjectState {
  final List<ProjectModel> project;

  const ProjectLoaded({required this.project});

  @override
  List<Object> get props => [project];
}

final class ProjectCreated extends ProjectState {
  final ProjectModel project;

  const ProjectCreated({required this.project});

  @override
  List<Object> get props => [project];
}

final class ProjectUpdated extends ProjectState {
  final ProjectModel project;

  const ProjectUpdated({required this.project});

  @override
  List<Object> get props => [project];
}

final class ProjectDeleted extends ProjectState {
  final int projectId;

  const ProjectDeleted({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

final class ProjectError extends ProjectState {
  final String message;

  const ProjectError({required this.message});

  @override
  List<Object> get props => [message];
}