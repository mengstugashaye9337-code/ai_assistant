import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:ai_assistant/core/database/app_database.dart';

class DriftMapper {
  static Service fromDatabaseRow(ServiceRow row) {
    return Service(
      id: row.id,
      name: row.name,
      description: row.description,
      price: row.price,
      durationMinutes: row.durationMinutes,
    );
  }
}
