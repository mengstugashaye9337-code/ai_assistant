import 'appointment.dart';
import 'time_slot.dart';

abstract class AppointmentsRepository {
  Future<List<Appointment>> getMyAppointments();
  Future<Appointment?> getAppointmentById(String id);
  Future<List<TimeSlot>> getBusyRange({
    required String providerId,
    required DateTime from,
    required DateTime to,
  });
  Future<Appointment> createAppointment(Appointment appointment);
  Future<Appointment> cancelAppointment(String id);
  Future<Appointment> rescheduleAppointment(String id, TimeSlot slot);
}

abstract class LocalAppointmentsRepository extends AppointmentsRepository {
  Future<void> upsertAppointments(List<Appointment> appointments);
}
