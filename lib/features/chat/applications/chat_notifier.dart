//import 'package:flutter/foundation.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context_factory.dart';
import 'package:ai_assistant/features/chat/domain/conversation_summary_services.dart';
import 'package:ai_assistant/features/chat/domain/summary_memory.dart';
import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';

//import 'package:ai_assistant/features/chat/infrustructure/provider/repository_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/summary_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/repository_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/supabase_message_provider.dart';

import 'chat_state.dart';
import 'package:ai_assistant/core/config/ai_config.dart';

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<ChatState> {
  late final AIRepository _repository;
  late final ConversationSummaryService _summaryService;
  late SummaryMemory _summaryMemory;
  late final ConversationRepository _supabaseMessage;

  @override
  ChatState build() {
    _repository = ref.read(aiRepositoryProvider);
    _summaryService = ref.read(conversationSummaryServiceProvider);
    _summaryMemory = SummaryMemory();
    _supabaseMessage = ref.read(supabaseMessagesRepositoryProvider);
    return ChatState.initial();
  }

  Future<void> sendMessage(String message) async {
    final userMessage = ChatMessage(text: message, sender: MessageSender.user);
    final aiMessage = ChatMessage(text: '', sender: MessageSender.ai);

    state = ChatState(
      messages: [...state.messages, userMessage, aiMessage],
      status: Streaming(),
    );
    try {
      final conversation = state.messages.where((m) {
        return !(m.sender == MessageSender.ai && m.text.isEmpty);
      }).toList();
      final recentStart = conversation.length > AIConfig.maxContextMessages
          ? conversation.length - AIConfig.maxContextMessages
          : 0;

      final newMessagesToSummarize =
          _summaryMemory.summarizedCount < recentStart
          ? conversation.sublist(_summaryMemory.summarizedCount, recentStart)
          : <ChatMessage>[];

      final String? summary;
      if (newMessagesToSummarize.isNotEmpty) {
        summary = await _summaryService.summarizeConversation(
          newMessagesToSummarize,
          _summaryMemory.summary,
        );
        _summaryMemory = _summaryMemory.copyWith(
          summary: summary,
          summarizedCount: recentStart,
        );
      } else {
        summary = _summaryMemory.summary;
      }
      final context = ConversationContextFactory.create(
        messages: conversation,
        summary: summary,
      );

      // 2. Send the sanitized history
      final stream = _repository.sendMessage(context);

      await for (final chunk in stream) {
        final updatedMessages = List<ChatMessage>.from(state.messages);
        final index = updatedMessages.length - 1;
        final currentText = updatedMessages[index].text;
        updatedMessages[index] = updatedMessages[index].copyWith(
          text: currentText + chunk,
        );
        state = state.copyWith(messages: updatedMessages);
      }
      state = state.copyWith(status: Idle());
    } catch (e, st) {
      print("========== GEMINI ERROR ==========");
      print(e);
      print(st);

      state = state.copyWith(status: ChatError());
    }
  }
}
