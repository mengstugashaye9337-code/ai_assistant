//import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context_factory.dart';

import 'package:ai_assistant/features/chat/infrustructure/provider/repository_provider.dart';
import 'chat_state.dart';

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<ChatState> {
  late final AIRepository _repository;

  @override
  ChatState build() {
    _repository = ref.read(aiRepositoryProvider);
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

      final context = ConversationContextFactory.create(
        messages: conversation,
        summary: '',
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
