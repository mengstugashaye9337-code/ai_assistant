import 'package:ai_assistant/features/chat/infrustructure/summary/summary_mapper.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/core/config/ai_config.dart';
import 'package:flutter/widgets.dart';

class SummaryBuilder {
  //SummaryBuilder();

  Map<String, dynamic> build(List<ChatMessage> messages, String? oldSummary) {
    const summary = {
      'role': 'system',
      'content': AIConfig.summaryInstruction ,
    };
    return {
      'model': AIConfig.model,
      'messages': [
        summary,
        if (oldSummary != null && oldSummary.isNotEmpty)
        {'role': 'system', 'content': 'Previous summary:\n$oldSummary'},

        ...messages.map(SummaryMapper.mapToSummary).toList(),
      ],
    };
  }
}
