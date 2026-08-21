import 'package:ai_assistant/core/config/ai_config.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context_factory.dart';
import 'package:ai_assistant/features/chat/domain/summary_memory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Conversation memory', () {
    test('SummaryMemory.copyWith updates only the provided fields', () {
      final memory = SummaryMemory(summary: 'old summary', summarizedCount: 2);

      final updated = memory.copyWith(summary: 'new summary');

      expect(updated.summary, 'new summary');
      expect(updated.summarizedCount, 2);

      final updatedAgain = memory.copyWith(summarizedCount: 5);

      expect(updatedAgain.summary, 'old summary');
      expect(updatedAgain.summarizedCount, 5);
    });

    test('ConversationContextFactory keeps only the most recent messages', () {
      final messages = [
        ChatMessage(text: 'm1', sender: MessageSender.user),
        ChatMessage(text: 'm2', sender: MessageSender.ai),
        ChatMessage(text: 'm3', sender: MessageSender.user),
        ChatMessage(text: 'm4', sender: MessageSender.ai),
        ChatMessage(text: 'm5', sender: MessageSender.user),
        ChatMessage(text: 'm6', sender: MessageSender.ai),
      ];

      final context = ConversationContextFactory.create(
        messages: messages,
        summary: 'active summary',
      );

      expect(context.summary, 'active summary');
      expect(context.recentMessages, hasLength(AIConfig.maxContextMessages));
      expect(context.recentMessages.map((message) => message.text).toList(), [
        'm2',
        'm3',
        'm4',
        'm5',
        'm6',
      ]);
    });

    test(
      'ConversationContextFactory keeps all messages when under the limit',
      () {
        final messages = [
          ChatMessage(text: 'm1', sender: MessageSender.user),
          ChatMessage(text: 'm2', sender: MessageSender.ai),
        ];

        final context = ConversationContextFactory.create(
          messages: messages,
          summary: 'recent summary',
        );

        expect(context.summary, 'recent summary');
        expect(context.recentMessages, messages);
      },
    );
  });
}
