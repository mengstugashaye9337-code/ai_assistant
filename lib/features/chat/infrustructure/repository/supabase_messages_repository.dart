import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';
import 'package:ai_assistant/features/chat/infrustructure/repository/supabase_messages_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMessagesRepository implements ConversationRepository {
  SupabaseMessagesRepository({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId);

    //final rows = response as List<dynamic>;
    return response.map(SupabaseMessagesMapper.fromSupabaseMap).toList();
  }

  @override
  Future<ChatMessage> saveMessage(
    String conversationId,
    ChatMessage message,
  ) async {
    final response = await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,

          ...SupabaseMessagesMapper.toSupabaseMap(message),
        })
        .select()
        .single();

    return SupabaseMessagesMapper.fromSupabaseMap(response);
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    await _client
        .from('messages')
        .delete()
        .eq('conversation_id', conversationId)
        .eq('id', messageId);
  }

  @override
  Future<void> updateMessage(
    String conversationId,
    String messageId,
    ChatMessage updatedMessage,
  ) async {
    await _client
        .from('messages')
        .update(SupabaseMessagesMapper.toSupabaseMap(updatedMessage))
        .eq('conversation_id', conversationId)
        .eq('id', messageId);
  }
}
