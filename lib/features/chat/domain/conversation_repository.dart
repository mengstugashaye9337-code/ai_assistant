import 'conversation.dart';

abstract class ConversationRepository {
  Future<Conversation> createConversation();

  Future<List<Conversation>> getConversations();

  Future<Conversation?> getConversation(String conversationId);

  Future<void> deleteConversation(String conversationId);
}
