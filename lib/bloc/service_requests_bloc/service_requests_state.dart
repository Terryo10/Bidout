part of 'service_requests_bloc.dart';

abstract class ServiceRequestsState extends Equatable {
  const ServiceRequestsState();

  @override
  List<Object?> get props => [];
}

class ServiceRequestsInitial extends ServiceRequestsState {}

class ServiceRequestsLoading extends ServiceRequestsState {}

class ServiceRequestsLoadingMore extends ServiceRequestsState {
  final List<ServiceRequestModel> currentRequests;

  const ServiceRequestsLoadingMore({required this.currentRequests});

  @override
  List<Object> get props => [currentRequests];
}

class ServiceRequestsLoaded extends ServiceRequestsState {
  final List<ServiceRequestModel> requests;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasReachedMax;
  final String? currentFilter;

  const ServiceRequestsLoaded({
    required this.requests,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasReachedMax,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [
        requests,
        currentPage,
        lastPage,
        total,
        hasReachedMax,
        currentFilter,
      ];

  ServiceRequestsLoaded copyWith({
    List<ServiceRequestModel>? requests,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasReachedMax,
    String? currentFilter,
  }) {
    return ServiceRequestsLoaded(
      requests: requests ?? this.requests,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class ServiceRequestsError extends ServiceRequestsState {
  final String message;

  const ServiceRequestsError({required this.message});

  @override
  List<Object> get props => [message];
}

class ServiceRequestCreating extends ServiceRequestsState {}

class ServiceRequestCreated extends ServiceRequestsState {
  final ServiceRequestModel serviceRequest;

  const ServiceRequestCreated({required this.serviceRequest});

  @override
  List<Object> get props => [serviceRequest];
}

class ServiceRequestCreateError extends ServiceRequestsState {
  final String message;

  const ServiceRequestCreateError({required this.message});

  @override
  List<Object> get props => [message];
}
