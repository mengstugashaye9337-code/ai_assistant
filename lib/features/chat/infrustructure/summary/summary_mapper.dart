import 'package:ai_assistant/features/chat/domain/chat_message.dart';

class SummaryMapper {
  static Map<String, dynamic> mapToSummary(ChatMessage message,) {
    return {
      'role': message.sender == MessageSender.user ? 'user' : 'assistant',
      'content': message.text,
      
    };
  }
}
