// lib/repositories/contractor_repo/contractor_repo.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/contractor/contractor_model.dart';
import '../../models/contractor/portfolio_model.dart';
import '../../models/contractor/contractor_review_model.dart';
import '../../models/pagination/pagination_model.dart';
import 'contractor_provider.dart';

class ContractorRepository {
  final FlutterSecureStorage storage;
  final ContractorProvider contractorProvider;

  ContractorRepository({
    required this.storage,
    required this.contractorProvider,
  });

  Future<PaginationModel<ContractorModel>> getContractors({
    int page = 1,
    int perPage = 10,
    String? search,
    List<String>? services,
    double? minRating,
    String? location,
    bool? isFeatured,
    bool? hasSubscription,
  }) async {
    return await contractorProvider.getContractors(
      page: page,
      perPage: perPage,
      search: search,
      services: services,
      minRating: minRating,
      location: location,
      isFeatured: isFeatured,
      hasSubscription: hasSubscription,
    );
  }

  Future<ContractorModel?> getContractor(int contractorId) async {
    return await contractorProvider.getContractor(contractorId);
  }

  Future<PaginationModel<PortfolioModel>> getContractorPortfolio(
    int contractorId, {
    int page = 1,
    int perPage = 10,
  }) async {
    return await contractorProvider.getContractorPortfolio(
      contractorId,
      page: page,
      perPage: perPage,
    );
  }

  Future<PaginationModel<PortfolioModel>> getMyPortfolio({
    int page = 1,
    int perPage = 10,
  }) async {
    return await contractorProvider.getMyPortfolio(
      page: page,
      perPage: perPage,
    );
  }

  Future<PortfolioModel> createPortfolio({
    required String title,
    required String description,
    String? projectType,
    DateTime? completionDate,
    double? projectValue,
    String? clientName,
    String? clientTestimonial,
    List<String>? tags,
    bool isFeatured = false,
    List<String> imagePaths = const [],
  }) async {
    return await contractorProvider.createPortfolio(
      title: title,
      description: description,
      projectType: projectType,
      completionDate: completionDate,
      projectValue: projectValue,
      clientName: clientName,
      clientTestimonial: clientTestimonial,
      tags: tags,
      isFeatured: isFeatured,
      imagePaths: imagePaths,
    );
  }

  Future<PortfolioModel> updatePortfolio(
    int portfolioId, {
    required String title,
    required String description,
    String? projectType,
    DateTime? completionDate,
    double? projectValue,
    String? clientName,
    String? clientTestimonial,
    List<String>? tags,
    bool isFeatured = false,
    List<String> imagePaths = const [],
  }) async {
    return await contractorProvider.updatePortfolio(
      portfolioId,
      title: title,
      description: description,
      projectType: projectType,
      completionDate: completionDate,
      projectValue: projectValue,
      clientName: clientName,
      clientTestimonial: clientTestimonial,
      tags: tags,
      isFeatured: isFeatured,
      imagePaths: imagePaths,
    );
  }

  Future<void> deletePortfolio(int portfolioId) async {
    return await contractorProvider.deletePortfolio(portfolioId);
  }

  Future<List<ContractorReviewModel>> getContractorReviews(
      int contractorId) async {
    return await contractorProvider.getContractorReviews(contractorId);
  }
}
