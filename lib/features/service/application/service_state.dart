import 'package:ai_assistant/features/service/domain/service.dart';

sealed class ServiceStatus {
  const ServiceStatus();
}

class ServiceIdle extends ServiceStatus {
  const ServiceIdle();
}

class ServiceLoaded extends ServiceStatus {
  const ServiceLoaded();
}

class ServiceLoading extends ServiceStatus {
  const ServiceLoading();
}

class ServiceError extends ServiceStatus {
  final Object error;
  final StackTrace stackTrace;

  const ServiceError({required this.error, required this.stackTrace});
}

class ServiceState {
  final List<Service> services;
  final Service? selectedService;
  final ServiceStatus status;

  const ServiceState({
    required this.services,
    required this.selectedService,
    required this.status,
  });

  factory ServiceState.initial() {
    return const ServiceState(
      services: [],
      selectedService: null,
      status: ServiceIdle(),
    );
  }

  ServiceState copyWith({
    List<Service>? services,
    Service? selectedService,
    ServiceStatus? status,
    bool clearSelectedService = false,
  }) {
    return ServiceState(
      services: services ?? this.services,
      selectedService: clearSelectedService
          ? null
          : (selectedService ?? this.selectedService),
      status: status ?? this.status,
    );
  }
}
