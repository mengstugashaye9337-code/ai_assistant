import 'package:ai_assistant/features/appointment/application/appointments_notifier.dart';
import 'package:ai_assistant/features/appointment/application/appointments_state.dart';
import 'package:ai_assistant/features/appointment/domain/appointment.dart';
import 'package:ai_assistant/features/appointment/domain/appointments_repository.dart';
import 'package:ai_assistant/features/appointment/domain/time_slot.dart';
import 'package:ai_assistant/features/appointment/infrastructure/provider/supabase_appointments_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final confirmed = Appointment(
    id: 'appointment-1',
    customerId: 'customer-1',
    providerId: 'provider-1',
    serviceId: 'service-1',
    startsAt: DateTime.utc(2026, 10, 9, 10),
    endsAt: DateTime.utc(2026, 10, 9, 10, 30),
    status: AppointmentStatus.confirmed,
    serviceName: 'Consultation',
    durationMinutes: 30,
    price: 50,
    createdAt: DateTime.utc(2026, 10, 1, 8),
  );

  test('loads the current customer appointments', () async {
    final container = ProviderContainer(
      overrides: [
        supabaseAppointmentsProvider.overrideWithValue(
          FakeAppointmentsRepository(mine: [confirmed]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appointmentsNotifierProvider.notifier).loadAppointments();

    final state = container.read(appointmentsNotifierProvider);
    expect(state.status, isA<AppointmentsLoaded>());
    expect(state.appointments, hasLength(1));
    expect(state.appointments.single.id, confirmed.id);
  });

  test('cancels an appointment and reloads the list', () async {
    final repository = FakeAppointmentsRepository(mine: [confirmed]);
    final container = ProviderContainer(
      overrides: [supabaseAppointmentsProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(appointmentsNotifierProvider.notifier);

    await notifier.loadAppointments();
    await notifier.cancelAppointment(confirmed.id);

    expect(
      container.read(appointmentsNotifierProvider).appointments.single.status,
      AppointmentStatus.cancelled,
    );
    expect(repository.cancelledIds, ['appointment-1']);
  });
}

class FakeAppointmentsRepository implements AppointmentsRepository {
  FakeAppointmentsRepository({required List<Appointment> mine})
    : _mine = List<Appointment>.from(mine);

  List<Appointment> _mine;
  final cancelledIds = <String>[];

  @override
  Future<Appointment> cancelAppointment(String id) async {
    cancelledIds.add(id);
    _mine = [
      for (final appointment in _mine)
        if (appointment.id == id)
          appointment.copyWith(status: AppointmentStatus.cancelled)
        else
          appointment,
    ];
    return _mine.firstWhere((appointment) => appointment.id == id);
  }

  @override
  Future<Appointment> createAppointment(Appointment appointment) {
    throw UnimplementedError();
  }

  @override
  Future<Appointment?> getAppointmentById(String id) async => null;

  @override
  Future<List<TimeSlot>> getBusyRange({
    required String providerId,
    required DateTime from,
    required DateTime to,
  }) async =>
      const [];

  @override
  Future<List<Appointment>> getMyAppointments() async => _mine;

  @override
  Future<Appointment> rescheduleAppointment(String id, TimeSlot slot) {
    throw UnimplementedError();
  }
}
