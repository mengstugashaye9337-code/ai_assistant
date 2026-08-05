import 'package:ai_assistant/features/chat/domain/chat_message.dart';

class SummaryMapper {
  static Map<String, dynamic> mapToSummary(ChatMessage message) {
    return {
      'role': message.sender == 'user' ? 'user' : 'system',
      'content': message.text,
    };
  }
}
