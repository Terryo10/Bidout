part of 'projects_bloc.dart';

sealed class ProjectsState extends Equatable {
  const ProjectsState();
  
  @override
  List<Object> get props => [];
}

final class ProjectsInitial extends ProjectsState {}
