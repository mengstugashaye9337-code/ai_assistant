import 'package:ai_assistant/features/chat/domain/chat_message.dart';

class SupabaseMessagesMapper {
  static Map<String, dynamic> toSupabaseMap(ChatMessage message) {
    return {
      'role': message.sender == MessageSender.ai ? 'assistant' : 'user',
      'content': message.text,
    };
  }

  static ChatMessage fromSupabaseMap(Map<String, dynamic> json) {
    final content = json['content'];
    final role = json['role'];
    final id = json['id'];
    return ChatMessage(
      text: content is String ? content : '',
      sender: role == 'assistant' ? MessageSender.ai : MessageSender.user,
      id: id is String ? id : null,
    );
  }
}
