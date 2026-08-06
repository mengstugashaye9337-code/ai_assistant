import 'package:ai_assistant/features/chat/infrustructure/summary/summary_mapper.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/core/config/ai_config.dart';

class SummaryBuilder {
  //SummaryBuilder();

  Map<String, dynamic> build(List<ChatMessage> messages) {
    const summary = {'role': 'system', 'content': AIConfig.summaryInstruction};
    return {
      'model': AIConfig.model,
      'messages': [
        summary,
        ...messages.map(SummaryMapper.mapToSummary).toList(),
      ],
    };
  }
}
