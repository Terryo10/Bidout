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
  final bool? userHasBid;

  const ContractorProjectsLoaded({
    required this.projects,
    required this.hasReachedMax,
    this.selectedProject,
    this.userHasBid,
  });

  @override
  List<Object?> get props =>
      [projects, hasReachedMax, selectedProject, userHasBid];

  ContractorProjectsLoaded copyWith({
    PaginationModel<ProjectModel>? projects,
    bool? hasReachedMax,
    ProjectModel? selectedProject,
    bool? userHasBid,
  }) {
    return ContractorProjectsLoaded(
      projects: projects ?? this.projects,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedProject: selectedProject ?? this.selectedProject,
      userHasBid: userHasBid ?? this.userHasBid,
    );
  }
}

final class ContractorProjectsError extends ContractorProjectsState {
  final String message;

  const ContractorProjectsError({required this.message});

  @override
  List<Object> get props => [message];
}
