import 'package:ai_assistant/features/appointment/domain/appointment.dart';
import 'package:ai_assistant/features/appointment/domain/appointments_repository.dart';
import 'package:ai_assistant/features/appointment/domain/time_slot.dart';
import 'package:ai_assistant/features/appointment/infrastructure/repository/supabase_appointments_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_assistant/features/appointment/domain/appointment_exceptions.dart';


class SupabaseAppointmentsRepository implements AppointmentsRepository {
  final SupabaseClient _client;

  SupabaseAppointmentsRepository({required SupabaseClient client})
    : _client = client;

  @override
  Future<List<Appointment>> getMyAppointments() async {
    final customerId = _requireUserId();
    final response = await _client
        .from('appointments')
        .select()
        .eq('customer_id', customerId)
        .order('starts_at');

    return response
        .map((row) => SupabaseAppointmentsMapper.fromSupabase(row))
        .toList();
  }

  @override
  Future<Appointment?> getAppointmentById(String id) async {
    final response = await _client
        .from('appointments')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return SupabaseAppointmentsMapper.fromSupabase(response);
  }

 @override
Future<List<TimeSlot>> getBusyRange({
  required String providerId,
  required DateTime from,
  required DateTime to,
}) async {
  final response = await _client.rpc(
    'get_provider_busy_ranges',
    params: {
      'p_provider_id': providerId,
      'p_from': from.toUtc().toIso8601String(),
      'p_to': to.toUtc().toIso8601String(),
    },
  );

  return (response as List).map((row) {
    return TimeSlot(
      start: DateTime.parse(row['starts_at'] as String).toUtc(),
      end: DateTime.parse(row['ends_at'] as String).toUtc(),
    );
  }).toList();
}
 @override
Future<Appointment> createAppointment(Appointment appointment) async {
  final payload = SupabaseAppointmentsMapper.toSupabase(appointment.copyWith(customerId: _requireUserId()),);

   try {
    final response = await _client
        .from('appointments')
        .insert(payload)
        .select()
        .single();

    return SupabaseAppointmentsMapper.fromSupabase(response);
  } on PostgrestException catch (error) {
    // 23P01 = exclusion violation (our no_double_booking rule)
    if (error.code == '23P01') {
      throw const SlotAlreadyTakenException();
    }
    rethrow;
  }
}

  @override
  Future<Appointment> cancelAppointment(String id) async {
    final response = await _client
        .from('appointments')
        .update({'status': AppointmentStatus.cancelled.name})
        .eq('id', id)
        .select()
        .single();

    return SupabaseAppointmentsMapper.fromSupabase(response);
  }

  @override
Future<Appointment> rescheduleAppointment(String id, TimeSlot slot) async {
  try {
    final response = await _client
        .from('appointments')
        .update({
          'starts_at': slot.start.toUtc().toIso8601String(),
          'ends_at': slot.end.toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return SupabaseAppointmentsMapper.fromSupabase(response);
  } on PostgrestException catch (error) {
    if (error.code == '23P01') {
      throw const SlotAlreadyTakenException();
    }
    rethrow;
  }
}

  String _requireUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }
    return user.id;
  }
}
