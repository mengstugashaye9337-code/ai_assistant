import 'package:ai_assistant/features/chat/infrustructure/summary/summary_mapper.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/core/config/ai_config.dart';

class SummaryBuilder {
  static Map<String, dynamic> buildSummary(List<ChatMessage> messages) {
    return {
      'model': AIConfig.model,
      'messages': messages.map(SummaryMapper.mapToSummary).toList(),
      'stream': AIConfig.stream,
    };
  }
}
