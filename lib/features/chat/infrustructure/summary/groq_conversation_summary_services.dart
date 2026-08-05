import 'package:ai_assistant/features/chat/domain/conversation_summary_services.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/infrustructure/repository/groq_client.dart';
import 'package:ai_assistant/features/chat/infrustructure/summary/summary_mapper.dart';
import 'package:ai_assistant/features/chat/infrustructure/summary/summary_builder.dart';

class GroqConversationSummaryService implements ConversationSummaryService {
  final GroqClient _client;
  final SummaryBuilder _builder;
  GroqConversationSummaryService({
    required GroqClient client,
    required SummaryBuilder builder,
  }) : _client = client,
       _builder = builder;

  @override
  Future<String> summarizeConversation(List<ChatMessage> messages) async {
    final requestBody = _builder.buildSummary(messages);
    final Summary = await _client.chat(requestBody);

    return Summary;
  }
}
