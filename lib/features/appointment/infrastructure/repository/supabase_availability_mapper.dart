import 'package:ai_assistant/features/appointment/domain/provider_availability_override.dart';
import 'package:ai_assistant/features/appointment/domain/provider_weekly_availability.dart';
import 'package:ai_assistant/features/appointment/domain/service_provider.dart';

class SupabaseAvailabilityMapper {
  static ServiceProvider providerFromSupabase(Map<String, dynamic> row) {
    return ServiceProvider(
      id: _requiredString(row, 'id'),
      name: _requiredString(row, 'name'),
    );
  }

  static ProviderWeeklyAvailability weeklyFromSupabase(
    Map<String, dynamic> row,
  ) {
    return ProviderWeeklyAvailability(
      id: _requiredString(row, 'id'),
      providerId: _requiredString(row, 'provider_id'),
      dayOfWeek: _requiredInt(row, 'day_of_week'),
      openMinutes: _requiredInt(row, 'open_minutes'),
      closeMinutes: _requiredInt(row, 'close_minutes'),
    );
  }

  static ProviderAvailabilityOverride overrideFromSupabase(
    Map<String, dynamic> row,
  ) {
    return ProviderAvailabilityOverride(
      id: _requiredString(row, 'id'),
      providerId: _requiredString(row, 'provider_id'),
      date: _requiredUtcDate(row, 'date'),
      openMinutes: _optionalInt(row, 'open_minutes'),
      closeMinutes: _optionalInt(row, 'close_minutes'),
      isClosed: _requiredBool(row, 'is_closed'),
    );
  }

  static String _requiredString(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException('Availability field "$key" must be a non-empty string');
  }

  static int _requiredInt(Map<String, dynamic> row, String key) {
    final value = _optionalInt(row, key);
    if (value == null) {
      throw FormatException('Availability field "$key" must be a whole number');
    }
    return value;
  }

  static int? _optionalInt(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num && value == value.truncate()) {
      return value.toInt();
    }
    throw FormatException('Availability field "$key" must be a whole number');
  }

  static bool _requiredBool(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is bool) {
      return value;
    }
    throw FormatException('Availability field "$key" must be a boolean');
  }

  static DateTime _requiredUtcDate(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is DateTime) {
      return DateTime.utc(value.year, value.month, value.day);
    }
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.parse(value);
      return DateTime.utc(parsed.year, parsed.month, parsed.day);
    }
    throw FormatException(
      'Availability field "$key" must be a DateTime or ISO date string',
    );
  }
}
