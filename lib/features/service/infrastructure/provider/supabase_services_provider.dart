import 'package:ai_assistant/features/auth/infrastructure/supabase_client_provider.dart';
import 'package:ai_assistant/features/service/domain/services_repository.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/supabase_services_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseServicesProvider = Provider<ServicesRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseServicesRepository(client: client);
});
