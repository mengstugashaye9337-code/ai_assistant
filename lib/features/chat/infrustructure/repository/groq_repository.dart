import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
//import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context.dart';

import 'package:ai_assistant/features/chat/infrustructure/services/groq_client.dart';
import 'package:ai_assistant/features/chat/infrustructure/repository/conversation_builder.dart';

class GroqRepository implements AIRepository {
  final GroqClient _client;
  final ConversationBuilder _builder;
  GroqRepository({
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
