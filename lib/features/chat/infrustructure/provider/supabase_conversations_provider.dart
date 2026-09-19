import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/auth/infrastructure/supabase_client_provider.dart';

import 'package:ai_assistant/features/chat/infrustructure/repository/supabase_conversations_repository.dart';

final supabaseConversationProvider = Provider<ConversationRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseConversationsRepository(client: client);
});
