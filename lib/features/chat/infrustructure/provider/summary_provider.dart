import 'package:ai_assistant/features/chat/infrustructure/services/groq_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/chat/infrustructure/summary/groq_conversation_summary_services.dart';
import 'package:ai_assistant/features/chat/domain/conversation_summary_services.dart';
import 'package:ai_assistant/features/chat/infrustructure/summary/summary_builder.dart';

final conversationSummaryServiceProvider = Provider<ConversationSummaryService>(
  (ref) {
    final client = ref.watch(groqClientProvider);
    final builder = SummaryBuilder();
    return GroqConversationSummaryService(client: client, builder: builder);
  },
);
