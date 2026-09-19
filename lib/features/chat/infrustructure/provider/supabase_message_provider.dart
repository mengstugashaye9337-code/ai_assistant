import 'package:ai_assistant/features/chat/domain/message_repository.dart';
import 'package:ai_assistant/features/auth/infrastructure/supabase_client_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/repository/supabase_messages_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseMessageRepositoryProvider = Provider<MessageRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseMessagesRepository(client: client);
});
