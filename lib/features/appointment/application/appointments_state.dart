import 'package:ai_assistant/features/appointment/domain/appointment.dart';

sealed class AppointmentsStatus {
  const AppointmentsStatus();
}

class AppointmentsIdle extends AppointmentsStatus {
  const AppointmentsIdle();
}

class AppointmentsLoading extends AppointmentsStatus {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends AppointmentsStatus {
  const AppointmentsLoaded();
}

class AppointmentsError extends AppointmentsStatus {
  final Object error;
  final StackTrace stackTrace;

  const AppointmentsError({required this.error, required this.stackTrace});
}

class AppointmentsState {
  final List<Appointment> appointments;
  final AppointmentsStatus status;

  const AppointmentsState({
    required this.appointments,
    required this.status,
  });

  factory AppointmentsState.initial() {
    return const AppointmentsState(
      appointments: [],
      status: AppointmentsIdle(),
    );
  }

  AppointmentsState copyWith({
    List<Appointment>? appointments,
    AppointmentsStatus? status,
  }) {
    return AppointmentsState(
      appointments: appointments ?? this.appointments,
      status: status ?? this.status,
    );
  }
}
