import 'package:ai_assistant/features/service/application/service_notifier.dart';
import 'package:ai_assistant/features/service/application/service_state.dart';
import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:ai_assistant/features/service/domain/services_repository.dart';
import 'package:ai_assistant/features/service/infrastructure/provider/local_first_services_provider.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/drift_services_repository.dart';
import 'package:ai_assistant/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  final firstService = Service(
    id: 'service-1',
    name: 'Consultation',
    description: 'Initial consultation',
    price: 50,
    durationMinutes: 30,
  );
  final secondService = Service(
    id: 'service-2',
    name: 'Follow-up',
    description: 'Follow-up appointment',
    price: 30,
    durationMinutes: 20,
  );

  ProviderContainer createContainer(ServicesRepository repository) {
    final container = ProviderContainer(
      overrides: [localFirstServicesProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts idle with no services or selection', () {
    final container = createContainer(FakeServicesRepository());

    final state = container.read(serviceNotifierProvider);

    expect(state.services, isEmpty);
    expect(state.selectedService, isNull);
    expect(state.status, isA<ServiceIdle>());
  });

  test('loads services from SQLite and exposes the loaded state', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.batch((batch) {
      batch.insertAll(database.services, [
        _serviceCompanion(firstService),
        _serviceCompanion(secondService),
      ]);
    });
    final repository = DriftServicesRepository(database: database);
    final container = createContainer(repository);
    final notifier = container.read(serviceNotifierProvider.notifier);

    expect(container.read(serviceNotifierProvider).status, isA<ServiceIdle>());

    final load = notifier.loadServices();

    expect(
      container.read(serviceNotifierProvider).status,
      isA<ServiceLoading>(),
    );

    await load;

    final state = container.read(serviceNotifierProvider);
    expect(state.services, hasLength(2));
    expect(state.services[0].id, firstService.id);
    expect(state.services[0].name, firstService.name);
    expect(state.services[0].description, firstService.description);
    expect(state.services[0].price, firstService.price);
    expect(state.services[0].durationMinutes, firstService.durationMinutes);
    expect(state.services[1].id, secondService.id);
    expect(state.services[1].name, secondService.name);
    expect(state.services[1].description, secondService.description);
    expect(state.services[1].price, secondService.price);
    expect(state.services[1].durationMinutes, secondService.durationMinutes);
    expect(state.status, isA<ServiceLoaded>());
  });

  test('exposes an error state when loading fails', () async {
    final repository = FakeServicesRepository(error: StateError('offline'));
    final container = createContainer(repository);

    await container.read(serviceNotifierProvider.notifier).loadServices();

    final status = container.read(serviceNotifierProvider).status;
    expect(status, isA<ServiceError>());
    expect((status as ServiceError).error, isA<StateError>());
  });

  test('selects and clears a service', () {
    final container = createContainer(FakeServicesRepository());
    final notifier = container.read(serviceNotifierProvider.notifier);

    notifier.selectService(firstService);
    expect(
      container.read(serviceNotifierProvider).selectedService,
      same(firstService),
    );

    notifier.clearSelected();
    expect(container.read(serviceNotifierProvider).selectedService, isNull);
  });
}

ServicesCompanion _serviceCompanion(Service service) {
  return ServicesCompanion.insert(
    id: service.id,
    name: service.name,
    description: service.description,
    price: service.price.toDouble(),
    durationMinutes: service.durationMinutes,
  );
}

class FakeServicesRepository implements ServicesRepository {
  FakeServicesRepository({this.services = const [], this.error});

  final List<Service> services;
  final Object? error;

  @override
  Future<List<Service>> getServices() async {
    if (error != null) {
      throw error!;
    }
    return services;
  }

  @override
  Future<Service?> getServiceById(String id) async {
    if (error != null) {
      throw error!;
    }
    for (final service in services) {
      if (service.id == id) return service;
    }
    return null;
  }
}
