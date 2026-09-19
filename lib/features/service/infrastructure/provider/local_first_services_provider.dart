import 'package:ai_assistant/features/auth/infrastructure/supabase_client_provider.dart';
import 'package:ai_assistant/features/service/domain/services_repository.dart';
import 'package:ai_assistant/features/service/infrastructure/provider/drift_services_provider.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/LocalFirstServicesCoordinator.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/drift_services_repository.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/supabase_services_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localFirstServicesProvider = Provider<ServicesRepository>((ref) {
  final local = ref.read(driftServicesRepositoryProvider);
  final remote = SupabaseServicesRepository(
    client: ref.read(supabaseClientProvider),
  );

  return LocalFirstServicesCoordinator(
    local: local as DriftServicesRepository,
    remote: remote,
  );
});
