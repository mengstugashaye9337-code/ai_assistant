import 'dart:developer' as developer;

import 'package:ai_assistant/features/appointment/application/appointments_state.dart';
import 'package:ai_assistant/features/appointment/domain/appointments_repository.dart';
import 'package:ai_assistant/features/appointment/infrastructure/provider/supabase_appointments_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final appointmentsNotifierProvider =
    NotifierProvider<AppointmentsNotifier, AppointmentsState>(
      AppointmentsNotifier.new,
    );

class AppointmentsNotifier extends Notifier<AppointmentsState> {
  late final AppointmentsRepository _appointmentsRepository;

  @override
  AppointmentsState build() {
    _appointmentsRepository = ref.read(supabaseAppointmentsProvider);
    return AppointmentsState.initial();
  }

  Future<void> loadAppointments() async {
    state = state.copyWith(status: const AppointmentsLoading());

    try {
      final appointments = await _appointmentsRepository.getMyAppointments();
      state = state.copyWith(
        appointments: appointments,
        status: const AppointmentsLoaded(),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Failed to load appointments',
        name: 'AppointmentsNotifier',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        status: AppointmentsError(error: error, stackTrace: stackTrace),
      );
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await _appointmentsRepository.cancelAppointment(id);
      await loadAppointments();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to cancel appointment',
        name: 'AppointmentsNotifier',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        status: AppointmentsError(error: error, stackTrace: stackTrace),
      );
    }
  }
}
