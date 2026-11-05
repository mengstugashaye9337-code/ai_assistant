import 'package:ai_assistant/features/appointment/application/booking_notifier.dart';
import 'package:ai_assistant/features/appointment/application/booking_state.dart';
import 'package:ai_assistant/features/appointment/domain/appointment.dart';
import 'package:ai_assistant/features/appointment/domain/appointments_repository.dart';
import 'package:ai_assistant/features/appointment/domain/availability_repository.dart';
import 'package:ai_assistant/features/appointment/domain/provider_availability_override.dart';
import 'package:ai_assistant/features/appointment/domain/provider_weekly_availability.dart';
import 'package:ai_assistant/features/appointment/domain/service_provider.dart';
import 'package:ai_assistant/features/appointment/domain/time_slot.dart';
import 'package:ai_assistant/features/appointment/infrastructure/provider/supabase_appointments_provider.dart';
import 'package:ai_assistant/features/appointment/infrastructure/provider/supabase_availability_provider.dart';
import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = Service(
    id: 'service-1',
    name: 'Consultation',
    description: 'Initial consultation',
    price: 50,
    durationMinutes: 30,
  );
  final provider = ServiceProvider(id: 'provider-1', name: 'Alex');

  List<ProviderWeeklyAvailability> weeklyForEveryDay({
    int openMinutes = 540,
    int closeMinutes = 1020,
  }) {
    return [
      for (var day = DateTime.monday; day <= DateTime.sunday; day++)
        ProviderWeeklyAvailability(
          id: 'weekly-$day',
          providerId: provider.id,
          dayOfWeek: day,
          openMinutes: openMinutes,
          closeMinutes: closeMinutes,
        ),
    ];
  }

  ProviderContainer createContainer({
    required AvailabilityRepository availability,
    required AppointmentsRepository appointments,
  }) {
    final container = ProviderContainer(
      overrides: [
        supabaseAvailabilityProvider.overrideWithValue(availability),
        supabaseAppointmentsProvider.overrideWithValue(appointments),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('auto-selects a single provider and loads bookable slots', () async {
    final availability = FakeAvailabilityRepository(
      providers: [provider],
      weekly: weeklyForEveryDay(),
    );
    final appointments = FakeAppointmentsRepository();
    final container = createContainer(
      availability: availability,
      appointments: appointments,
    );

    final notifier = container.read(bookingNotifierProvider.notifier);
    await notifier.start(service);
    await notifier.selectDay(DateTime.utc(2026, 12, 4));

    final state = container.read(bookingNotifierProvider);
    expect(state.status, isA<BookingReady>());
    expect(state.selectedProvider?.id, provider.id);
    expect(state.slots, isNotEmpty);
    expect(state.slots.first.end.difference(state.slots.first.start).inMinutes, 30);
  });

  test('returns no slots when the selected day is overridden closed', () async {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final availability = FakeAvailabilityRepository(
      providers: [provider],
      weekly: weeklyForEveryDay(),
      overrides: [
        ProviderAvailabilityOverride(
          id: 'closed',
          providerId: provider.id,
          date: today,
          isClosed: true,
        ),
      ],
    );
    final container = createContainer(
      availability: availability,
      appointments: FakeAppointmentsRepository(),
    );

    await container.read(bookingNotifierProvider.notifier).start(service);

    final state = container.read(bookingNotifierProvider);
    expect(state.status, isA<BookingReady>());
    expect(state.slots, isEmpty);
  });

  test('creates an appointment for the selected slot', () async {
    final appointments = FakeAppointmentsRepository();
    final container = createContainer(
      availability: FakeAvailabilityRepository(
        providers: [provider],
        weekly: weeklyForEveryDay(),
      ),
      appointments: appointments,
    );
    final notifier = container.read(bookingNotifierProvider.notifier);

    await notifier.start(service);
    await notifier.selectDay(DateTime.utc(2026, 12, 4));
    final slot = container.read(bookingNotifierProvider).slots.first;
    notifier.selectSlot(slot);
    await notifier.confirmBooking();

    expect(container.read(bookingNotifierProvider).status, isA<BookingBooked>());
    expect(appointments.created, isNotEmpty);
    expect(appointments.created.single.providerId, provider.id);
    expect(appointments.created.single.serviceId, service.id);
    expect(appointments.created.single.startsAt, slot.start);
  });
}

class FakeAvailabilityRepository implements AvailabilityRepository {
  FakeAvailabilityRepository({
    this.providers = const [],
    this.weekly = const [],
    this.overrides = const [],
  });

  final List<ServiceProvider> providers;
  final List<ProviderWeeklyAvailability> weekly;
  final List<ProviderAvailabilityOverride> overrides;

  @override
  Future<List<ServiceProvider>> getProviders() async => providers;

  @override
  Future<List<ProviderWeeklyAvailability>> getWeeklyAvailability(
    String providerId,
  ) async {
    return weekly.where((row) => row.providerId == providerId).toList();
  }

  @override
  Future<List<ProviderAvailabilityOverride>> getOverrides({
    required String providerId,
    required DateTime from,
    required DateTime to,
  }) async {
    return overrides
        .where(
          (row) =>
              row.providerId == providerId &&
              !row.date.toUtc().isBefore(from.toUtc()) &&
              row.date.toUtc().isBefore(to.toUtc()),
        )
        .toList();
  }
}

class FakeAppointmentsRepository implements AppointmentsRepository {
  FakeAppointmentsRepository({this.mine = const [], this.busy = const []});

  final List<Appointment> mine;
  final List<TimeSlot> busy;
  final List<Appointment> created = [];

  @override
  Future<Appointment> cancelAppointment(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Appointment> createAppointment(Appointment appointment) async {
    created.add(appointment);
    return appointment.copyWith(id: 'created-1', customerId: 'customer-1');
  }

  @override
  Future<Appointment?> getAppointmentById(String id) async => null;

  @override
  Future<List<TimeSlot>> getBusyRange({
    required String providerId,
    required DateTime from,
    required DateTime to,
  }) async {
    return busy;
  }

  @override
  Future<List<Appointment>> getMyAppointments() async => mine;

  @override
  Future<Appointment> rescheduleAppointment(String id, TimeSlot slot) {
    throw UnimplementedError();
  }
}
