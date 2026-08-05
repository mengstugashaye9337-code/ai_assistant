import 'package:ai_assistant/core/config/ai_config.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';

class ConversationContextFactory {
  const ConversationContextFactory();
  static ConversationContext create({
    required List<ChatMessage> messages,
    String? summary,
  }) {
    final recentMessages = messages.length > AIConfig.maxContextMessages
        ? messages.sublist(messages.length - AIConfig.maxContextMessages)
        : messages;

    return ConversationContext(
      summary: summary,
      recentMessages: recentMessages,
    );
  }
}


import 'package:ai_assistant/core/config/ai_config.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';

class ConversationContextFactory {
  const ConversationContextFactory();

  static ConversationContext create({required List<ChatMessage> messages, String? summary}){
  final recentMessages = messages.length > AIConfig.maxContextMessages
        ? messages.sublist(messages.length - AIConfig.maxContextMessages)
        : messages;

    return ConversationContext(recentMessages: recentMessages, summary: summary);
   


  }

}

