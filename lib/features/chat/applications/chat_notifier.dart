import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/core/config/ai_config.dart';
import 'package:ai_assistant/features/chat/applications/chat_state.dart';
import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
//import 'package:ai_assistant/features/chat/domain/conversation.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context_factory.dart';
import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';
import 'package:ai_assistant/features/chat/domain/conversation_summary_services.dart';
import 'package:ai_assistant/features/chat/domain/message_repository.dart';
import 'package:ai_assistant/features/chat/domain/summary_memory.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/repository_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/summary_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/supabase_conversations_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/supabase_message_provider.dart';

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<ChatState> {
  late final AIRepository _aiRepository;
  late final ConversationSummaryService _summaryService;
  late final ConversationRepository _conversationRepository;
  late final MessageRepository _messageRepository;
  late SummaryMemory _summaryMemory;

  @override
  ChatState build() {
    _aiRepository = ref.read(aiRepositoryProvider);
    _summaryService = ref.read(conversationSummaryServiceProvider);
    _conversationRepository = ref.read(supabaseConversationProvider);
    _messageRepository = ref.read(supabaseMessageRepositoryProvider);
    _summaryMemory = SummaryMemory();

    return ChatState.initial();
  }

  void startNewChat() {
    _resetSummaryMemory();
    state = ChatState.initial();
  }

  Future<void> openConversation(String conversationId) async {
    try {
      final messages = await _messageRepository.getMessages(conversationId);
      _resetSummaryMemory();

      state = ChatState(
        conversationId: conversationId,
        messages: messages,
        status: Idle(),
      );
    } catch (e, st) {
      print('========== OPEN CONVERSATION ERROR ==========');
      print(e);
      print(st);

      state = state.copyWith(status: ChatError());
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;

    await _messageRepository.deleteMessage(conversationId, messageId);
    state = state.copyWith(
      messages: state.messages
          .where((message) => message.id != messageId)
          .toList(),
    );
  }

  Future<void> updateMessage(
    String messageId,
    ChatMessage updatedMessage,
  ) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;

    await _messageRepository.updateMessage(
      conversationId,
      messageId,
      updatedMessage,
    );
    state = state.copyWith(
      messages: state.messages
          .map((message) => message.id == messageId ? updatedMessage : message)
          .toList(),
    );
  }

  Future<void> sendMessage(String message) async {
    final userMessage = ChatMessage(text: message, sender: MessageSender.user);

    try {
      var conversationId = state.conversationId;
      if (conversationId == null) {
        final conversation = await _conversationRepository.createConversation();
        conversationId = conversation.id;
        state = state.copyWith(conversationId: conversationId);
      }

      final savedUserMessage = await _messageRepository.saveMessage(
        conversationId,
        userMessage,
      );
      final aiMessage = ChatMessage(text: '', sender: MessageSender.ai);

      state = state.copyWith(
        messages: [...state.messages, savedUserMessage, aiMessage],
        status: Streaming(),
      );

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

      final stream = _aiRepository.sendMessage(context);
      var completedAiText = '';

      await for (final chunk in stream) {
        completedAiText += chunk;
        final updatedMessages = List<ChatMessage>.from(state.messages);
        final aiIndex = updatedMessages.length - 1;
        updatedMessages[aiIndex] = aiMessage.copyWith(text: completedAiText);
        state = state.copyWith(messages: updatedMessages);
      }

      final savedAiMessage = await _messageRepository.saveMessage(
        conversationId,
        aiMessage.copyWith(text: completedAiText),
      );
      final messagesWithSavedAi = List<ChatMessage>.from(state.messages);
      messagesWithSavedAi[messagesWithSavedAi.length - 1] = savedAiMessage;

      state = state.copyWith(messages: messagesWithSavedAi, status: Idle());
    } catch (e, st) {
      print('========== SEND MESSAGE ERROR ==========');
      print(e);
      print(st);

      state = state.copyWith(status: ChatError());
    }
  }

  void _resetSummaryMemory() {
    _summaryMemory = SummaryMemory();
  }
}
