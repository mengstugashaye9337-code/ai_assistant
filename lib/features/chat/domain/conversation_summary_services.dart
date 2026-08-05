import 'package:ai_assistant/features/chat/domain/chat_message.dart';

abstract class ConversationSummaryService {
  Stream<String> summarizeConversation(List<ChatMessage> messages);
}
