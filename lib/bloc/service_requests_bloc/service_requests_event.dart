part of 'service_requests_bloc.dart';

abstract class ServiceRequestsEvent extends Equatable {
  const ServiceRequestsEvent();

  @override
  List<Object?> get props => [];
}

class ServiceRequestsLoadRequested extends ServiceRequestsEvent {
  final int page;
  final String? status;
  final bool refresh;

  const ServiceRequestsLoadRequested({
    this.page = 1,
    this.status,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, status, refresh];
}

class ServiceRequestsLoadMoreRequested extends ServiceRequestsEvent {
  const ServiceRequestsLoadMoreRequested();
}

class ServiceRequestCreateRequested extends ServiceRequestsEvent {
  final int contractorId;
  final String message;

  const ServiceRequestCreateRequested({
    required this.contractorId,
    required this.message,
  });

  @override
  List<Object> get props => [contractorId, message];
}

class ServiceRequestStatusUpdateRequested extends ServiceRequestsEvent {
  final int id;
  final String status;

  const ServiceRequestStatusUpdateRequested({
    required this.id,
    required this.status,
  });

  @override
  List<Object> get props => [id, status];
}

class ServiceRequestRefreshRequested extends ServiceRequestsEvent {
  const ServiceRequestRefreshRequested();
}

class ServiceRequestFilterChanged extends ServiceRequestsEvent {
  final String? status;

  const ServiceRequestFilterChanged({this.status});

  @override
  List<Object?> get props => [status];
}
