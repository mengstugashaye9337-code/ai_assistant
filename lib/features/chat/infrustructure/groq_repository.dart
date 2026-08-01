import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';

import 'package:ai_assistant/features/chat/infrustructure/groq_service.dart';

class GroqRepositroy implements AIRepository {
  final GroqClient _client;
  GroqRepositroy({required GroqClient client}) : _client = client;

  Stream<String> sendMessage(List<ChatMessage> messages) async* {
    final requestBody = {
      'model': 'llama-3.3-70b-versatile',
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'stream': true,
    };

    final stream = _client.chat(requestBody);

    yield* stream;
  }
}
