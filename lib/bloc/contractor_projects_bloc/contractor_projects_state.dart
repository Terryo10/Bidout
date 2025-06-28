part of 'contractor_projects_bloc.dart';

sealed class ContractorProjectsState extends Equatable {
  const ContractorProjectsState();

  @override
  List<Object?> get props => [];
}

final class ContractorProjectsInitial extends ContractorProjectsState {}

final class ContractorProjectsLoading extends ContractorProjectsState {}

final class ContractorProjectsSingleLoading extends ContractorProjectsState {}

final class ContractorProjectsLoaded extends ContractorProjectsState {
  final PaginationModel<ProjectModel> projects;
  final bool hasReachedMax;
  final ProjectModel? selectedProject;

  const ContractorProjectsLoaded({
    required this.projects,
    required this.hasReachedMax,
    this.selectedProject,
  });

  @override
  List<Object?> get props => [projects, hasReachedMax, selectedProject];

  ContractorProjectsLoaded copyWith({
    PaginationModel<ProjectModel>? projects,
    bool? hasReachedMax,
    ProjectModel? selectedProject,
  }) {
    return ContractorProjectsLoaded(
      projects: projects ?? this.projects,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedProject: selectedProject ?? this.selectedProject,
    );
  }
}

final class ContractorProjectsError extends ContractorProjectsState {
  final String message;

  const ContractorProjectsError({required this.message});

  @override
  List<Object> get props => [message];
}
