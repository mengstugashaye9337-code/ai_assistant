import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_assistant/features/auth/infrastructure/supabase_client_provider.dart';

import 'package:ai_assistant/features/chat/infrustructure/repository/supabase_messages_repository.dart';

final supabaseMessagesRepositoryProvider = Provider<ConversationRepository>((
  ref,
) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseMessagesRepository(client: client);
});
