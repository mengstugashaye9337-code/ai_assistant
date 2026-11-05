import 'package:ai_assistant/features/appointment/domain/appointments_repository.dart';
import 'package:ai_assistant/features/appointment/infrastructure/repository/supabase_appointments_repository.dart';
import 'package:ai_assistant/features/auth/infrastructure/supabase_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseAppointmentsProvider = Provider<AppointmentsRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseAppointmentsRepository(client: client);
});
