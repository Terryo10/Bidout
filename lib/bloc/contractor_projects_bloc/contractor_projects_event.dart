part of 'contractor_projects_bloc.dart';

sealed class ContractorProjectsEvent extends Equatable {
  const ContractorProjectsEvent();

  @override
  List<Object?> get props => [];
}

class ContractorProjectsLoadRequested extends ContractorProjectsEvent {
  final int page;
  final int perPage;
  final String? search;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const ContractorProjectsLoadRequested({
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

class ContractorProjectsLoadMoreRequested extends ContractorProjectsEvent {
  final int perPage;
  final String? search;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const ContractorProjectsLoadMoreRequested({
    this.perPage = 10,
    this.search,
    this.status,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [perPage, search, status, sortBy, sortOrder];
}

class ContractorProjectsRefreshRequested extends ContractorProjectsEvent {
  final int perPage;
  final String? search;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const ContractorProjectsRefreshRequested({
    this.perPage = 10,
    this.search,
    this.status,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [perPage, search, status, sortBy, sortOrder];
}

class ContractorProjectsSearchRequested extends ContractorProjectsEvent {
  final String query;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const ContractorProjectsSearchRequested({
    required this.query,
    this.status,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [query, status, sortBy, sortOrder];
}

class ContractorProjectsSingleLoadRequested extends ContractorProjectsEvent {
  final int projectId;

  const ContractorProjectsSingleLoadRequested({required this.projectId});

  @override
  List<Object> get props => [projectId];
}
