import 'package:ai_assistant/features/appointment/domain/appointment.dart';

class SupabaseAppointmentsMapper {
  static Appointment fromSupabase(Map<String, dynamic> row) {
    return Appointment(
      id: _requiredString(row, 'id'),
      customerId: _requiredString(row, 'customer_id'),
      serviceId: _requiredString(row, 'service_id'),
      startsAt: _requiredUtcDateTime(row, 'starts_at'),
      endsAt: _requiredUtcDateTime(row, 'ends_at'),
      status: _requiredStatus(row, 'status'),
      serviceName: _requiredString(row, 'service_name'),
      durationMinutes: _requiredInt(row, 'duration_minutes'),
      price: _requiredNum(row, 'price'),
      createdAt: _requiredUtcDateTime(row, 'created_at'),
      providerId: _requiredString(row, 'provider_id'),
      providerName: _requiredString(row, 'provider_name'),
    );
  }

  static Map<String, dynamic> toSupabase(Appointment appointment) {
    return {
      if (appointment.id.isNotEmpty) 'id': appointment.id,
      'customer_id': appointment.customerId,
      'provider_id': appointment.providerId,
      'service_id': appointment.serviceId,
      'starts_at': appointment.startsAt.toUtc().toIso8601String(),
      'ends_at': appointment.endsAt.toUtc().toIso8601String(),
      'status': appointment.status.name,
      'service_name': appointment.serviceName,
      'duration_minutes': appointment.durationMinutes,
      'price': appointment.price,
      'provider_name': appointment.providerName,
    };
  }

  static String _requiredString(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException(
      'Appointment field "$key" must be a non-empty string',
    );
  }




  static num _requiredNum(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is num) {
      return value;
    }
    throw FormatException('Appointment field "$key" must be numeric');
  }

  static int _requiredInt(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is int) {
      return value;
    }
    if (value is num && value == value.truncate()) {
      return value.toInt();
    }
    throw FormatException('Appointment field "$key" must be a whole number');
  }

  static DateTime _requiredUtcDateTime(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toUtc();
    }
    throw FormatException(
      'Appointment field "$key" must be a DateTime or ISO-8601 string',
    );
  }

  static AppointmentStatus _requiredStatus(
    Map<String, dynamic> row,
    String key,
  ) {
    final value = _requiredString(row, key);
    for (final status in AppointmentStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    throw FormatException('Appointment field "$key" must be a valid status');
  }
}
