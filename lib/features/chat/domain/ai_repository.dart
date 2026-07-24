import 'package:ai_assistant/features/chat/domain/chat_message.dart';

abstract class AIRepository {
  Stream<String> sendMessage(List<ChatMessage> messages);
}
