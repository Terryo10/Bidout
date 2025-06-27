import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/auth/api_error_model.dart';
import '../../models/services/service_model.dart';
import '../../repositories/projects_repo/projects_repository.dart';

part 'services_event.dart';
part 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final ProjectRepository projectRepository;

  ServicesBloc({required this.projectRepository}) : super(ServicesInitial()) {
    on<ServicesLoadRequested>(_onServicesLoadRequested);
  }

  Future<void> _onServicesLoadRequested(
    ServicesLoadRequested event,
    Emitter<ServicesState> emit,
  ) async {
    emit(ServicesLoading());

    try {
      final services = await projectRepository.getServices();
      emit(ServicesLoaded(services: services));
    } catch (e) {
      print(e.toString());
      if (e is ApiErrorModel) {
        print(e.firstError);
        emit(ServicesError(message: e.firstError));
      } else {
        emit(const ServicesError(
            message: 'Failed to load services. Please try again.'));
      }
    }
  }
}
