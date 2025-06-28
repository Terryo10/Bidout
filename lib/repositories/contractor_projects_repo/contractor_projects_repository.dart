import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/pagination/pagination_model.dart';
import '../../models/projects/project_model.dart';
import 'contractor_projects_provider.dart';

class ContractorProjectsRepository {
  final FlutterSecureStorage storage;
  final ContractorProjectsProvider contractorProjectsProvider;

  ContractorProjectsRepository({
    required this.storage,
    required this.contractorProjectsProvider,
  });

  Future<PaginationModel<ProjectModel>> getAvailableProjects({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    return await contractorProjectsProvider.getAvailableProjects(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  Future<ProjectModel?> getProject(int projectId) async {
    return await contractorProjectsProvider.getProject(projectId);
  }
}
