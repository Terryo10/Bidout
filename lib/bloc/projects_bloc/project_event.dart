part of 'project_bloc.dart';


sealed class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class ProjectLoadRequested extends ProjectEvent {}

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