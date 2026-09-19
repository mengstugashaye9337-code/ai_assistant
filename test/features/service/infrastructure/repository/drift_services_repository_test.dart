import 'package:ai_assistant/core/database/app_database.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/drift_services_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftServicesRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftServicesRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('getServices returns all stored services', () async {
    await database.batch((batch) {
      batch.insertAll(database.services, [
        _serviceCompanion(id: 'service-1', name: 'Consultation'),
        _serviceCompanion(id: 'service-2', name: 'Follow-up'),
      ]);
    });

    final services = await repository.getServices();

    expect(services, hasLength(2));
    expect(
      services.map((service) => service.id),
      containsAll(['service-1', 'service-2']),
    );

    final consultation = services.singleWhere(
      (service) => service.id == 'service-1',
    );
    expect(consultation.name, 'Consultation');
    expect(consultation.description, 'Initial consultation');
    expect(consultation.price, 50.0);
    expect(consultation.durationMinutes, 30);
  });

  test(
    'getServices returns an empty list when no services are stored',
    () async {
      expect(await repository.getServices(), isEmpty);
    },
  );

  test('getServiceById returns the matching service', () async {
    await database
        .into(database.services)
        .insert(_serviceCompanion(id: 'service-1', name: 'Consultation'));

    final service = await repository.getServiceById('service-1');

    expect(service, isNotNull);
    expect(service!.id, 'service-1');
    expect(service.name, 'Consultation');
  });

  test('getServiceById returns null when the service is missing', () async {
    final service = await repository.getServiceById('missing-service');

    expect(service, isNull);
  });
}

ServicesCompanion _serviceCompanion({
  required String id,
  required String name,
}) {
  return ServicesCompanion.insert(
    id: id,
    name: name,
    description: 'Initial consultation',
    price: 50.0,
    durationMinutes: 30,
  );
}
