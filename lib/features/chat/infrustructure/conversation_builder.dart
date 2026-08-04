import 'package:ai_assistant/features/chat/domain/conversation_context.dart';
import 'package:ai_assistant/features/chat/infrustructure/groqmessage_mapper.dart';
import 'package:ai_assistant/core/config/ai_config.dart';
import 'package:flutter/foundation.dart';

class ConversationBuilder {
  static const instruction = 'all instruction is here ';

  static const Map<String, dynamic> jsonMessage = {
    'role': 'system',
    'content': instruction,
  };

  Map<String, dynamic> build(ConversationContext context) {
    final List<Map<String, dynamic>> jsonMessages = [
      jsonMessage,
      Summary,
      ...context.recentMessages.map(GroqmessageMapper.toJson).toList(),
    ];
    return {'model': AIConfig.model, 'messages': jsonMessages, 'stream': true};
  }
}
