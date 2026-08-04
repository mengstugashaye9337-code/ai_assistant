import 'package:ai_assistant/features/chat/domain/chat_message.dart';

class ConversationContext {
  final String? summary;
  final List<ChatMessage> recentMessages;

  const ConversationContext({
    required this.summary,
    required this.recentMessages,
  });

  ConversationContext copyWith({
    List<ChatMessage>? recentmessage,
    String? contextMessages,
  }) {
    return ConversationContext(
      recentMessages: recentmessage ?? recentMessages,
      summary: contextMessages ?? summary,
    );
  }
}
