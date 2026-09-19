import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/chat/domain/conversation.dart';
import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/supabase_conversations_provider.dart';
import 'conversations_state.dart';

final conversationsNotifierProvider =
    NotifierProvider<ConversationNotifier, ConversationsState>(
      ConversationNotifier.new,
    );

class ConversationNotifier extends Notifier<ConversationsState> {
  late final ConversationRepository _conversationRepository;

  @override
  ConversationsState build() {
    _conversationRepository = ref.read(supabaseConversationProvider);

    return ConversationsState.initial();
  }

  Future<List<Conversation>> getConversations() {
    return _conversationRepository.getConversations();
  }

  Future<Conversation?> getConversation(String conversationId) {
    return _conversationRepository.getConversation(conversationId);
  }

  Future<void> deleteConversation(String conversationId) async {
    await _conversationRepository.deleteConversation(conversationId);
  }
}
