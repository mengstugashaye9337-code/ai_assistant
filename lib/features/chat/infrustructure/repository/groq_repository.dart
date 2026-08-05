import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
//import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context.dart';

import 'package:ai_assistant/features/chat/infrustructure/groq_client.dart';
import 'package:ai_assistant/features/chat/infrustructure/conversation_builder.dart';

class GroqRepositroy implements AIRepository {
  final GroqClient _client;
  final ConversationBuilder _builder;
  GroqRepositroy({
    required GroqClient client,
    required ConversationBuilder builder,
  }) : _client = client,
       _builder = builder;
  @override
  Stream<String> sendMessage(ConversationContext context) async* {
    final requestBody = _builder.build(context);

    final stream = _client.chat(requestBody);

    yield* stream;
  }
}
