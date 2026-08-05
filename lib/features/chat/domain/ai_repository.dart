//import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context.dart';

abstract class AIRepository {
  Stream<String> sendMessage(ConversationContext context);
}
