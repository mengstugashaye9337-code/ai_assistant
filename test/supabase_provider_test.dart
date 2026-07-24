import 'package:ai_assistant/features/auth/infrastructure/supabase_auth_repository.dart';
import 'package:ai_assistant/features/auth/infrastructure/supabase_auth_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'auth repository provider resolves from the Supabase client provider',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repository = container.read(supabaseClientProvider);

      expect(repository, isA<SupabaseAuthRepository>());
      expect(repository, isNotNull);
    },
  );
}
