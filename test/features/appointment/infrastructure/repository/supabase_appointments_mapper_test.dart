import 'package:ai_assistant/features/appointment/domain/appointment.dart';
import 'package:ai_assistant/features/appointment/infrastructure/repository/supabase_appointments_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a valid Supabase row to an Appointment in UTC', () {
    final appointment = SupabaseAppointmentsMapper.fromSupabase({
      'id': 'appointment-1',
      'customer_id': 'customer-1',
      'provider_id': 'provider-1',
      'service_id': 'service-1',
      'starts_at': '2026-10-04T10:00:00+00:00',
      'ends_at': '2026-10-04T10:30:00+00:00',
      'status': 'confirmed',
      'service_name': 'Consultation',
      'duration_minutes': 30,
      'price': 50.0,
      'created_at': '2026-10-01T08:00:00+00:00',
    });

    expect(appointment.id, 'appointment-1');
    expect(appointment.customerId, 'customer-1');
    expect(appointment.providerId, 'provider-1');
    expect(appointment.serviceId, 'service-1');
    expect(appointment.startsAt.isUtc, isTrue);
    expect(appointment.startsAt, DateTime.utc(2026, 10, 4, 10));
    expect(appointment.endsAt, DateTime.utc(2026, 10, 4, 10, 30));
    expect(appointment.status, AppointmentStatus.confirmed);
    expect(appointment.serviceName, 'Consultation');
    expect(appointment.durationMinutes, 30);
    expect(appointment.price, 50.0);
  });

  test('writes UTC ISO-8601 timestamps and provider_id', () {
    final row = SupabaseAppointmentsMapper.toSupabase(
      Appointment(
        id: 'appointment-1',
        customerId: 'customer-1',
        providerId: 'provider-1',
        serviceId: 'service-1',
        startsAt: DateTime(2026, 10, 4, 13),
        endsAt: DateTime(2026, 10, 4, 13, 30),
        status: AppointmentStatus.confirmed,
        serviceName: 'Consultation',
        durationMinutes: 30,
        price: 50,
        createdAt: DateTime.utc(2026, 10, 1, 8),
      ),
    );

    expect(row['starts_at'], DateTime(2026, 10, 4, 13).toUtc().toIso8601String());
    expect(row['ends_at'], DateTime(2026, 10, 4, 13, 30).toUtc().toIso8601String());
    expect(row['status'], 'confirmed');
    expect(row['customer_id'], 'customer-1');
    expect(row['provider_id'], 'provider-1');
    expect(row['service_id'], 'service-1');
    expect(row['service_name'], 'Consultation');
    expect(row['duration_minutes'], 30);
    expect(row['price'], 50);
  });

  test('omits empty appointment ids so the database can generate them', () {
    final row = SupabaseAppointmentsMapper.toSupabase(
      Appointment(
        id: '',
        customerId: 'customer-1',
        providerId: 'provider-1',
        serviceId: 'service-1',
        startsAt: DateTime.utc(2026, 10, 4, 13),
        endsAt: DateTime.utc(2026, 10, 4, 13, 30),
        status: AppointmentStatus.confirmed,
        serviceName: 'Consultation',
        durationMinutes: 30,
        price: 50,
        createdAt: DateTime.utc(2026, 10, 1, 8),
      ),
    );

    expect(row.containsKey('id'), isFalse);
  });

  test('rejects rows with missing required fields', () {
    final row = _validRow()..remove('service_name');

    expect(
      () => SupabaseAppointmentsMapper.fromSupabase(row),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects rows with invalid field types', () {
    final row = _validRow()..['price'] = '50';

    expect(
      () => SupabaseAppointmentsMapper.fromSupabase(row),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unknown status values', () {
    final row = _validRow()..['status'] = 'pending';

    expect(
      () => SupabaseAppointmentsMapper.fromSupabase(row),
      throwsA(isA<FormatException>()),
    );
  });

  test('accepts an integral numeric duration', () {
    final row = _validRow()..['duration_minutes'] = 30.0;

    final appointment = SupabaseAppointmentsMapper.fromSupabase(row);

    expect(appointment.durationMinutes, 30);
  });
}

Map<String, dynamic> _validRow() {
  return {
    'id': 'appointment-1',
    'customer_id': 'customer-1',
    'provider_id': 'provider-1',
    'service_id': 'service-1',
    'starts_at': '2026-10-04T10:00:00Z',
    'ends_at': '2026-10-04T10:30:00Z',
    'status': 'confirmed',
    'service_name': 'Consultation',
    'duration_minutes': 30,
    'price': 50,
    'created_at': '2026-10-01T08:00:00Z',
  };
}
