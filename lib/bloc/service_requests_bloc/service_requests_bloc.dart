import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/service_request_model.dart';
import '../../repositories/service_requests_repo/service_requests_repository.dart';

part 'service_requests_event.dart';
part 'service_requests_state.dart';

class ServiceRequestsBloc
    extends Bloc<ServiceRequestsEvent, ServiceRequestsState> {
  final ServiceRequestsRepository serviceRequestsRepository;

  ServiceRequestsBloc({required this.serviceRequestsRepository})
      : super(ServiceRequestsInitial()) {
    on<ServiceRequestsLoadRequested>(_onServiceRequestsLoadRequested);
    on<ServiceRequestsLoadMoreRequested>(_onServiceRequestsLoadMoreRequested);
    on<ServiceRequestCreateRequested>(_onServiceRequestCreateRequested);
    on<ServiceRequestStatusUpdateRequested>(
        _onServiceRequestStatusUpdateRequested);
    on<ServiceRequestRefreshRequested>(_onServiceRequestRefreshRequested);
    on<ServiceRequestFilterChanged>(_onServiceRequestFilterChanged);
  }

  Future<void> _onServiceRequestsLoadRequested(
    ServiceRequestsLoadRequested event,
    Emitter<ServiceRequestsState> emit,
  ) async {
    if (event.refresh || state is ServiceRequestsInitial) {
      emit(ServiceRequestsLoading());
    }

    try {
      final response = await serviceRequestsRepository.getServiceRequests(
        page: event.page,
        status: event.status,
      );

      emit(ServiceRequestsLoaded(
        requests: response.data,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        hasReachedMax: response.currentPage >= response.lastPage,
        currentFilter: event.status,
      ));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ServiceRequestsError(message: e.firstError));
      } else {
        emit(const ServiceRequestsError(
            message: 'Failed to load service requests'));
      }
    }
  }

  Future<void> _onServiceRequestsLoadMoreRequested(
    ServiceRequestsLoadMoreRequested event,
    Emitter<ServiceRequestsState> emit,
  ) async {
    if (state is ServiceRequestsLoaded) {
      final currentState = state as ServiceRequestsLoaded;

      if (currentState.hasReachedMax) return;

      emit(ServiceRequestsLoadingMore(currentRequests: currentState.requests));

      try {
        final response = await serviceRequestsRepository.getServiceRequests(
          page: currentState.currentPage + 1,
          status: currentState.currentFilter,
        );

        emit(ServiceRequestsLoaded(
          requests: currentState.requests + response.data,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          total: response.total,
          hasReachedMax: response.currentPage >= response.lastPage,
          currentFilter: currentState.currentFilter,
        ));
      } catch (e) {
        emit(ServiceRequestsLoaded(
          requests: currentState.requests,
          currentPage: currentState.currentPage,
          lastPage: currentState.lastPage,
          total: currentState.total,
          hasReachedMax: currentState.hasReachedMax,
          currentFilter: currentState.currentFilter,
        ));
      }
    }
  }

  Future<void> _onServiceRequestCreateRequested(
    ServiceRequestCreateRequested event,
    Emitter<ServiceRequestsState> emit,
  ) async {
    emit(ServiceRequestCreating());

    try {
      final serviceRequest =
          await serviceRequestsRepository.createServiceRequest(
        CreateServiceRequestModel(
          contractorId: event.contractorId,
          message: event.message,
        ),
      );

      emit(ServiceRequestCreated(serviceRequest: serviceRequest));

      // Refresh the list after creating
      add(const ServiceRequestsLoadRequested(refresh: true));
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ServiceRequestCreateError(message: e.firstError));
      } else {
        emit(const ServiceRequestCreateError(
            message: 'Failed to send service request'));
      }
    }
  }

  Future<void> _onServiceRequestStatusUpdateRequested(
    ServiceRequestStatusUpdateRequested event,
    Emitter<ServiceRequestsState> emit,
  ) async {
    try {
      await serviceRequestsRepository.updateServiceRequestStatus(
        event.id,
        event.status,
      );

      // Refresh the list after updating
      if (state is ServiceRequestsLoaded) {
        final currentState = state as ServiceRequestsLoaded;
        add(ServiceRequestsLoadRequested(
          status: currentState.currentFilter,
          refresh: true,
        ));
      } else {
        add(const ServiceRequestsLoadRequested(refresh: true));
      }
    } catch (e) {
      if (e is ApiErrorModel) {
        emit(ServiceRequestsError(message: e.firstError));
      } else {
        emit(const ServiceRequestsError(
            message: 'Failed to update service request'));
      }
    }
  }

  Future<void> _onServiceRequestRefreshRequested(
    ServiceRequestRefreshRequested event,
    Emitter<ServiceRequestsState> emit,
  ) async {
    String? currentFilter;
    if (state is ServiceRequestsLoaded) {
      currentFilter = (state as ServiceRequestsLoaded).currentFilter;
    }

    add(ServiceRequestsLoadRequested(
      status: currentFilter,
      refresh: true,
    ));
  }

  Future<void> _onServiceRequestFilterChanged(
    ServiceRequestFilterChanged event,
    Emitter<ServiceRequestsState> emit,
  ) async {
    add(ServiceRequestsLoadRequested(
      status: event.status,
      refresh: true,
    ));
  }
}
