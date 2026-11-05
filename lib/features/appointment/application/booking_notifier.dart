import 'dart:developer' as developer;

import 'package:ai_assistant/features/appointment/application/booking_state.dart';
import 'package:ai_assistant/features/appointment/domain/appointment.dart';
import 'package:ai_assistant/features/appointment/domain/appointments_repository.dart';
import 'package:ai_assistant/features/appointment/domain/availability_repository.dart';
import 'package:ai_assistant/features/appointment/domain/service_provider.dart';
import 'package:ai_assistant/features/appointment/domain/slot_generator.dart';
import 'package:ai_assistant/features/appointment/domain/time_slot.dart';
import 'package:ai_assistant/features/appointment/infrastructure/provider/supabase_appointments_provider.dart';
import 'package:ai_assistant/features/appointment/infrastructure/provider/supabase_availability_provider.dart';
import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/core/time/salon_time.dart';
import 'package:ai_assistant/features/appointment/domain/appointment_exceptions.dart';

final bookingNotifierProvider =
    NotifierProvider<BookingNotifier, BookingState>(BookingNotifier.new);

class BookingNotifier extends Notifier<BookingState> {
  late final AvailabilityRepository _availabilityRepository;
  late final AppointmentsRepository _appointmentsRepository;
  final SlotGenerator _slotGenerator = SlotGenerator();

  @override
  BookingState build() {
    _availabilityRepository = ref.read(supabaseAvailabilityProvider);
    _appointmentsRepository = ref.read(supabaseAppointmentsProvider);
    return BookingState.initial();
  }

  Future<void> start(Service service) async {
    state = BookingState.initial().copyWith(
      service: service,
      status: const BookingLoading(),
    );

    try {
      final providers = await _availabilityRepository.getProviders();
      final selected = providers.length == 1 ? providers.first : null;
      final day = salonToday();

      state = state.copyWith(
        providers: providers,
        selectedProvider: selected,
        selectedDay: day,
        status: const BookingReady(),
      );

      if (selected != null) {
        await loadSlots();
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to start booking',
        name: 'BookingNotifier',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        status: BookingError(error: error, stackTrace: stackTrace),
      );
    }
  }

  Future<void> selectProvider(ServiceProvider provider) async {
    state = state.copyWith(
      selectedProvider: provider,
      clearSelectedSlot: true,
    );
    await loadSlots();
  }

  Future<void> selectDay(DateTime day) async {
    state = state.copyWith(
    selectedDay: DateTime.utc(day.year, day.month, day.day),      
    clearSelectedSlot: true,
    );
    await loadSlots();
  }

  void selectSlot(TimeSlot slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  void clearNotice() {
    state = state.copyWith(clearNotice: true);
  }

  Future<void> loadSlots() async {
    final service = state.service;
    final provider = state.selectedProvider;
    final day = state.selectedDay;
    if (service == null || provider == null || day == null) {
      state = state.copyWith(slots: const [], clearSelectedSlot: true);
      return;
    }

    state = state.copyWith(slots: const [], status: const BookingReady());

    try {
      final now = DateTime.now().toUtc();
      final dayStart = salonDayStart(day); // real UTC moment: salon midnight
      final dayEnd = dayStart.add(const Duration(days: 1));
      final rangeStart = now.isAfter(dayStart) ? now : dayStart;
      final nextDay = day.add(const Duration(days: 1)); // a salon date label

      final weekly = await _availabilityRepository.getWeeklyAvailability(
        provider.id,
      );
      final overrides = await _availabilityRepository.getOverrides(
        providerId: provider.id,
        from: day,
        to: nextDay,
      );
      final busy = await _appointmentsRepository.getBusyRange(
        providerId: provider.id,
        from: rangeStart,
        to: dayEnd,
      );
      final slots = _slotGenerator.generate(
        rangeStart: rangeStart,
        rangeEnd: dayEnd,
        durationMinutes: service.durationMinutes,
        weekly: weekly,
        overrides: overrides,
        busy: busy,
      );

      state = state.copyWith(slots: slots, status: const BookingReady());
    } catch (error, stackTrace) {
      developer.log(
        'Failed to load booking slots',
        name: 'BookingNotifier',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        status: BookingError(error: error, stackTrace: stackTrace),
      );
    }
  }

Future<void> confirmBooking() async {
  final service = state.service;
  final provider = state.selectedProvider;
  final slot = state.selectedSlot;
  if (service == null || provider == null || slot == null) {
    return;
  }

  state = state.copyWith(isSubmitting: true);

  try {
    await _appointmentsRepository.createAppointment(
      Appointment(
        id: '',
        customerId: '',
        providerId: provider.id,
        providerName: provider.name,
        serviceId: service.id,
        startsAt: slot.start,
        endsAt: slot.end,
        status: AppointmentStatus.confirmed,
        serviceName: service.name,
        durationMinutes: service.durationMinutes,
        price: service.price,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    state = state.copyWith(
      isSubmitting: false,
      status: const BookingBooked(),
    );
  } on SlotAlreadyTakenException {
    // NEW: the slot was taken by someone else
    state = state.copyWith(
      isSubmitting: false,
      clearSelectedSlot: true,
      notice: 'That time was just taken. Please pick another.',
    );
    await loadSlots();
  } catch (error, stackTrace) {
    // your existing catch, unchanged
    developer.log(
      'Failed to create appointment',
      name: 'BookingNotifier',
      error: error,
      stackTrace: stackTrace,
    );
    state = state.copyWith(
      isSubmitting: false,
      status: BookingError(error: error, stackTrace: stackTrace),
    );
  }
}

 
}
