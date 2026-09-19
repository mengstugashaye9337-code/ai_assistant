import 'package:ai_assistant/features/chat/applications/chat_notifier.dart';
import 'package:ai_assistant/features/chat/applications/chat_state.dart';
import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context.dart';
import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';
import 'package:ai_assistant/features/chat/domain/conversation_summary_services.dart';
import 'package:ai_assistant/features/chat/domain/message_repository.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/repository_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/summary_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/supabase_conversations_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/supabase_message_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAIRepository implements AIRepository {
  @override
  Stream<String> sendMessage(ConversationContext context) async* {}
}

class FakeSummaryService implements ConversationSummaryService {
  @override
  Future<String> summarizeConversation(
    List<ChatMessage> messages,
    String? oldSummary,
  ) async {
    return oldSummary ?? '';
  }
}

class FakeConversationRepository implements ConversationRepository {
  @override
  Future<Conversation> createConversation() async {
    return Conversation(
      id: 'new-id',
      userId: 'user-1',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {}

  @override
  Future<Conversation?> getConversation(String conversationId) async => null;

  @override
  Future<List<Conversation>> getConversations() async => [];
}

class FakeMessageRepository implements MessageRepository {
  final Map<String, List<ChatMessage>> messagesByConversation;

  FakeMessageRepository({required this.messagesByConversation});

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {}

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    return messagesByConversation[conversationId] ?? [];
  }

  @override
  Future<ChatMessage> saveMessage(
    String conversationId,
    ChatMessage message,
  ) async {
    return message.copyWith(id: 'saved-id');
  }

  @override
  Future<void> updateMessage(
    String conversationId,
    String messageId,
    ChatMessage updatedMessage,
  ) async {}
}

void main() {
  group('ChatNotifier lifecycle', () {
    late ProviderContainer container;
    late FakeMessageRepository messageRepository;

    setUp(() {
      messageRepository = FakeMessageRepository(
        messagesByConversation: {
          'C1': [
            const ChatMessage(
              id: 'M1',
              text: 'Hello',
              sender: MessageSender.user,
            ),
            const ChatMessage(
              id: 'M2',
              text: 'Hi there',
              sender: MessageSender.ai,
            ),
          ],
        },
      );

      container = ProviderContainer(
        overrides: [
          aiRepositoryProvider.overrideWithValue(FakeAIRepository()),
          conversationSummaryServiceProvider.overrideWithValue(
            FakeSummaryService(),
          ),
          supabaseConversationRepositoryProvider.overrideWithValue(
            FakeConversationRepository(),
          ),
          supabaseMessageRepositoryProvider.overrideWithValue(
            messageRepository,
          ),
        ],
      );
      container.read(chatNotifierProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('startNewChat clears active conversation state', () async {
      final notifier = container.read(chatNotifierProvider.notifier);

      await notifier.openConversation('C1');
      notifier.startNewChat();

      final state = container.read(chatNotifierProvider);
      expect(state.conversationId, isNull);
      expect(state.messages, isEmpty);
      expect(state.status, isA<Idle>());
    });

    test('openConversation loads messages for the selected conversation', () async {
      final notifier = container.read(chatNotifierProvider.notifier);

      await notifier.openConversation('C1');

      final state = container.read(chatNotifierProvider);
      expect(state.conversationId, 'C1');
      expect(state.messages, hasLength(2));
      expect(state.messages.first.text, 'Hello');
      expect(state.status, isA<Idle>());
    });
  });
}
