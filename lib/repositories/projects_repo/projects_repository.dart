import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/projects/project_model.dart';
import '../../models/projects/project_request_model.dart' as request;
import '../../models/services/service_model.dart' as service;
import 'projects_provider.dart';

class ProjectRepository {
  final FlutterSecureStorage storage;
  final ProjectProvider projectProvider;

  ProjectRepository({
    required this.storage,
    required this.projectProvider,
  });

  Future<List<ProjectModel>> getProjects() async {
    return await projectProvider.getProjects();
  }

  Future<ProjectModel> createProject(
      request.ProjectRequestModel request) async {
    return await projectProvider.createProject(request);
  }

  Future<ProjectModel> updateProject(
      int projectId, request.ProjectRequestModel request) async {
    return await projectProvider.updateProject(projectId, request);
  }

  Future<void> deleteProject(int projectId) async {
    await projectProvider.deleteProject(projectId);
  }

  Future<List<service.ServiceModel>> getServices() async {
    return await projectProvider.getServices();
  }
}
