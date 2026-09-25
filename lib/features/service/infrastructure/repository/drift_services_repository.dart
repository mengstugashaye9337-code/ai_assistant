import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:ai_assistant/core/database/app_database.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/drift_maper.dart';
import 'package:ai_assistant/features/service/domain/services_repository.dart';

class DriftServicesRepository implements  LocalServicesRepository {
  final AppDatabase _database;

  DriftServicesRepository({required AppDatabase database})
    : _database = database;
@override
  Future<List<Service>> getServices() async {
    final rows = await _database.select(_database.services).get();
    return rows.map((row) => DriftMapper.fromDatabaseRow(row)).toList();
  }

  @override
  Future<void> replaceServices(List<Service> services) async {
    await _database.transaction(() async {
      await _database.delete(_database.services).go();
      await _database.batch((batch) {
        batch.insertAll(
          _database.services,
          services
              .map(
                (service) => ServicesCompanion.insert(
                  id: service.id,
                  name: service.name,
                  description: service.description,
                  price: service.price.toDouble(),
                  durationMinutes: service.durationMinutes,
                ),
              )
              .toList(),
        );
      });
    });
  }
@override
  Future<Service?> getServiceById(String id) async {
    final query = _database.select(_database.services)
      ..where((row) => row.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return DriftMapper.fromDatabaseRow(row);
  }
}
