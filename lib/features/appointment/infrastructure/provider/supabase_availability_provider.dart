import 'package:ai_assistant/features/appointment/domain/availability_repository.dart';
import 'package:ai_assistant/features/appointment/infrastructure/repository/supabase_availability_repository.dart';
import 'package:ai_assistant/features/auth/infrastructure/supabase_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseAvailabilityProvider = Provider<AvailabilityRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseAvailabilityRepository(client: client);
});
