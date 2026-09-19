import 'package:ai_assistant/features/service/domain/service.dart';

class SupabaseServicesMapper {
  static Service fromSupabase(Map<String, dynamic> row) {
    return Service(
      id: _requiredString(row, 'id'),
      name: _requiredString(row, 'name'),
      description: _requiredString(row, 'description'),
      price: _requiredNum(row, 'price'),
      durationMinutes: _requiredInt(row, 'duration_minutes'),
    );
  }

  static String _requiredString(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException('Service field "$key" must be a non-empty string');
  }

  static num _requiredNum(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is num) {
      return value;
    }
    throw FormatException('Service field "$key" must be numeric');
  }

  static int _requiredInt(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is int) {
      return value;
    }
    if (value is num && value == value.truncate()) {
      return value.toInt();
    }
    throw FormatException('Service field "$key" must be a whole number');
  }

  static Map<String, dynamic> toSupabase(Service service) {
    return {
      'name': service.name,
      'description': service.description,
      'price': service.price,
      'duration_minutes': service.durationMinutes,
    };
  }
}
