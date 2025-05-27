part of 'portfolio_bloc.dart';

sealed class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

class PortfolioLoadRequested extends PortfolioEvent {
  final int page;
  final int perPage;

  const PortfolioLoadRequested({
    this.page = 1,
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [page, perPage];
}

class PortfolioLoadMoreRequested extends PortfolioEvent {
  final int perPage;

  const PortfolioLoadMoreRequested({
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [perPage];
}

class PortfolioRefreshRequested extends PortfolioEvent {
  final int perPage;

  const PortfolioRefreshRequested({
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [perPage];
}

class PortfolioCreateRequested extends PortfolioEvent {
  final String title;
  final String description;
  final String? projectType;
  final DateTime? completionDate;
  final double? projectValue;
  final String? clientName;
  final String? clientTestimonial;
  final List<String>? tags;
  final bool isFeatured;
  final List<String> imagePaths;

  const PortfolioCreateRequested({
    required this.title,
    required this.description,
    this.projectType,
    this.completionDate,
    this.projectValue,
    this.clientName,
    this.clientTestimonial,
    this.tags,
    this.isFeatured = false,
    this.imagePaths = const [],
  });

  @override
  List<Object?> get props => [
    title, description, projectType, completionDate, projectValue,
    clientName, clientTestimonial, tags, isFeatured, imagePaths,
  ];
}

class PortfolioUpdateRequested extends PortfolioEvent {
  final int portfolioId;
  final String title;
  final String description;
  final String? projectType;
  final DateTime? completionDate;
  final double? projectValue;
  final String? clientName;
  final String? clientTestimonial;
  final List<String>? tags;
  final bool isFeatured;
  final List<String> imagePaths;

  const PortfolioUpdateRequested({
    required this.portfolioId,
    required this.title,
    required this.description,
    this.projectType,
    this.completionDate,
    this.projectValue,
    this.clientName,
    this.clientTestimonial,
    this.tags,
    this.isFeatured = false,
    this.imagePaths = const [],
  });

  @override
  List<Object?> get props => [
    portfolioId, title, description, projectType, completionDate, projectValue,
    clientName, clientTestimonial, tags, isFeatured, imagePaths,
  ];
}

class PortfolioDeleteRequested extends PortfolioEvent {
  final int portfolioId;

  const PortfolioDeleteRequested({required this.portfolioId});

  @override
  List<Object> get props => [portfolioId];
}

class ContractorPortfolioLoadRequested extends PortfolioEvent {
  final int contractorId;
  final int page;
  final int perPage;

  const ContractorPortfolioLoadRequested({
    required this.contractorId,
    this.page = 1,
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [contractorId, page, perPage];
}
