import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';

import 'package:ai_assistant/features/chat/infrustructure/groq_client.dart';
import 'package:ai_assistant/features/chat/infrustructure/conversation_builder.dart';

class GroqRepositroy implements AIRepository {
  final GroqClient _client;
  GroqRepositroy({required GroqClient client}) : _client = client;
  @override
  Stream<String> sendMessage(List<ChatMessage> messages) async* {
    final builder = ConversationBuilder();
    final requestBody = builder.build(messages);

    final stream = _client.chat(requestBody);

    yield* stream;
  }
}
