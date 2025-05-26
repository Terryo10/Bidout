

import '../pagination/pagination_model.dart';
import 'project_model.dart';

class ProjectsResponseModel {
  final PaginationModel<ProjectModel> projects;

  ProjectsResponseModel({required this.projects});

  factory ProjectsResponseModel.fromJson(Map<String, dynamic> json) {
    return ProjectsResponseModel(
      projects: PaginationModel<ProjectModel>.fromJson(
        json['projects'],
        (projectJson) => ProjectModel.fromJson(projectJson),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projects': {
        'current_page': projects.currentPage,
        'data': projects.data.map((project) => project.toJson()).toList(),
        'first_page_url': projects.firstPageUrl,
        'from': projects.from,
        'last_page': projects.lastPage,
        'last_page_url': projects.lastPageUrl,
        'links': projects.links.map((link) => link.toJson()).toList(),
        'next_page_url': projects.nextPageUrl,
        'path': projects.path,
        'per_page': projects.perPage,
        'prev_page_url': projects.prevPageUrl,
        'to': projects.to,
        'total': projects.total,
      },
    };
  }
}