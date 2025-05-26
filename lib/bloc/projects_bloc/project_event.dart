part of 'project_bloc.dart';

sealed class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class ProjectLoadRequested extends ProjectEvent {
  final int page;
  final int perPage;
  final String? search;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const ProjectLoadRequested({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.status,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [page, perPage, search, status, sortBy, sortOrder];
}

class ProjectLoadMoreRequested extends ProjectEvent {
  final int perPage;
  final String? search;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const ProjectLoadMoreRequested({
    this.perPage = 10,
    this.search,
    this.status,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [perPage, search, status, sortBy, sortOrder];
}

class ProjectRefreshRequested extends ProjectEvent {
  final int perPage;
  final String? search;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const ProjectRefreshRequested({
    this.perPage = 10,
    this.search,
    this.status,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [perPage, search, status, sortBy, sortOrder];
}

class ProjectSearchRequested extends ProjectEvent {
  final String query;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const ProjectSearchRequested({
    required this.query,
    this.status,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [query, status, sortBy, sortOrder];
}

class ProjectSingleLoadRequested extends ProjectEvent {
  final int projectId;

  const ProjectSingleLoadRequested({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

class ProjectCreateRequested extends ProjectEvent {
  final String title;
  final String description;
  final String? additionalRequirements;
  final double budget;
  final String frequency;
  final String keyFactor;
  final DateTime startDate;
  final DateTime endDate;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final int serviceId;
  final List<String> imagePaths;
  final bool isDrafted;

  const ProjectCreateRequested({
    required this.title,
    required this.description,
    this.additionalRequirements,
    required this.budget,
    required this.frequency,
    required this.keyFactor,
    required this.startDate,
    required this.endDate,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    required this.serviceId,
    required this.imagePaths,
    required this.isDrafted,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        additionalRequirements,
        budget,
        frequency,
        keyFactor,
        startDate,
        endDate,
        street,
        city,
        state,
        zipCode,
        serviceId,
        imagePaths,
        isDrafted,
      ];
}

class ProjectUpdateRequested extends ProjectEvent {
  final int projectId;
  final String title;
  final String description;
  final String? additionalRequirements;
  final double budget;
  final String frequency;
  final String keyFactor;
  final DateTime startDate;
  final DateTime endDate;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final int serviceId;
  final List<String> imagePaths;
  final bool isDrafted;

  const ProjectUpdateRequested({
    required this.projectId,
    required this.title,
    required this.description,
    this.additionalRequirements,
    required this.budget,
    required this.frequency,
    required this.keyFactor,
    required this.startDate,
    required this.endDate,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    required this.serviceId,
    required this.imagePaths,
    required this.isDrafted,
  });

  @override
  List<Object?> get props => [
        projectId,
        title,
        description,
        additionalRequirements,
        budget,
        frequency,
        keyFactor,
        startDate,
        endDate,
        street,
        city,
        state,
        zipCode,
        serviceId,
        imagePaths,
        isDrafted,
      ];
}

class ProjectDeleteRequested extends ProjectEvent {
  final int projectId;

  const ProjectDeleteRequested({required this.projectId});

  @override
  List<Object> get props => [projectId];
}