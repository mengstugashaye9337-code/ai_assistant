import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/service/domain/services_repository.dart';
import 'package:ai_assistant/features/service/domain/service.dart';

import 'package:ai_assistant/features/service/infrastructure/provider/local_first_services_provider.dart';
import 'service_state.dart';

//import 'package:riverpod_annotation/riverpod_annotation.dart';

final serviceNotifierProvider = NotifierProvider<ServiceNotifier, ServiceState>(
  ServiceNotifier.new,
);

//part 'service_notifier.g.dart';
//@riverpod
class ServiceNotifier extends Notifier<ServiceState> {
  late final ServicesRepository _servicesRepository;
  @override
  ServiceState build() {
    _servicesRepository = ref.read(localFirstServicesProvider);
    return ServiceState.initial();
  }

  Future<void> loadServices() async {
    state = state.copyWith(status: const ServiceLoading());

    try {
      final services = await _servicesRepository.getServices();

      state = state.copyWith(services: services, status: const ServiceLoaded());
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch services',
        name: 'ServiceNotifier',
        error: error,
        stackTrace: stackTrace,
      );

      state = state.copyWith(
        status: ServiceError(error: error, stackTrace: stackTrace),
      );
    }
  }

  void selectService(Service service) {
    state = state.copyWith(selectedService: service);
  }

  void clearSelected() {
    state = state.copyWith(clearSelectedService: true);
  }
}
