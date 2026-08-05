import 'package:ai_assistant/features/chat/domain/chat_message.dart';

class GroqmessageMapper {
  static Map<String, dynamic> toJson(ChatMessage message) {
    return {
      'role': message.sender == MessageSender.ai ? 'assistant' : 'user',
      'content': message.text,
    };
  }

  // static ChatMessage fromGroqMessage(Map<String, dynamic> json) {
  //   return ChatMessage(
  //     text: json['content'] as String,
  //     sender: json['role'] == 'assistant'
  //         ? MessageSender.ai
  //         : MessageSender.user,
  //   );
  // }
}
