import 'package:ai_assistant/features/chat/domain/chat_message.dart';

abstract class MessageRepository {
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<ChatMessage> saveMessage(String? conversationId, ChatMessage message);
  Future<void> deleteMessage(String conversationId, String messageId);
  Future<void> updateMessage(
    String conversationId,
    String messageId,
    ChatMessage updatedMessage,
  );
}
