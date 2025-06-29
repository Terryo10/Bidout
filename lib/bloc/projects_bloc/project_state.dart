part of 'project_bloc.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

final class ProjectInitial extends ProjectState {}

final class ProjectLoading extends ProjectState {}

final class ProjectSingleLoading extends ProjectState {}

final class ProjectLoaded extends ProjectState {
  final PaginationModel<ProjectModel> projects;
  final bool hasReachedMax;
  final ProjectModel? selectedProject;
  final bool? userHasBid;

  const ProjectLoaded({
    required this.projects,
    required this.hasReachedMax,
    this.selectedProject,
    this.userHasBid,
  });

  @override
  List<Object?> get props =>
      [projects, hasReachedMax, selectedProject, userHasBid];

  ProjectLoaded copyWith({
    PaginationModel<ProjectModel>? projects,
    bool? hasReachedMax,
    ProjectModel? selectedProject,
    bool? userHasBid,
  }) {
    return ProjectLoaded(
      projects: projects ?? this.projects,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedProject: selectedProject ?? this.selectedProject,
      userHasBid: userHasBid ?? this.userHasBid,
    );
  }
}

final class ProjectSingleLoaded extends ProjectState {
  final ProjectModel project;
  final bool? userHasBid;

  const ProjectSingleLoaded({
    required this.project,
    this.userHasBid,
  });

  @override
  List<Object?> get props => [project, userHasBid];
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
