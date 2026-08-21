import 'package:ai_assistant/features/chat/domain/conversation.dart';
import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_conversations_mapper.dart';

class SupabaseConversationsRepository implements ConversationRepository {
  final SupabaseClient _client;
  SupabaseConversationsRepository({required SupabaseClient client})
    : _client = client;

  @override
  Future<Conversation> createConversation() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }
    final response = await _client
        .from('conversations')
        .insert({'user_id': user.id})
        .select()
        .single();
    return SupabaseConversationsMapper.fromSupabase(response);
  }

  @override
  Future<List<Conversation>> getConversations() async {
    final response = await _client
        .from('conversations')
        .select()
        .order('updated_at', ascending: false);

    return response
        .map((row) => SupabaseConversationsMapper.fromSupabase(row))
        .toList();
  }

  @override
  Future<Conversation?> getConversation(String conversationId) async {
    final response = await _client
        .from('conversations')
        .select()
        .eq('id', conversationId)
        .maybeSingle();
    if (response == null) return null;
    return SupabaseConversationsMapper.fromSupabase(response);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _client.from('conversations').delete().eq('id', conversationId);
  }
}
