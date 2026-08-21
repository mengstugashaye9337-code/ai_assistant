import 'package:ai_assistant/core/config/ai_config.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/conversation_context_factory.dart';
import 'package:ai_assistant/features/chat/domain/summary_memory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SummaryMemory', () {
    test('copyWith updates only the provided fields', () {
      final original = SummaryMemory(
        summary: 'old summary',
        summarizedCount: 2,
      );

      final updated = original.copyWith(summary: 'new summary');
      final updatedCount = original.copyWith(summarizedCount: 5);

      expect(updated.summary, 'new summary');
      expect(updated.summarizedCount, 2);

      expect(updatedCount.summary, 'old summary');
      expect(updatedCount.summarizedCount, 5);
    });

    test(
      'does not summarize the same messages again once summarizedCount reaches recentStart',
      () {
        final conversation = [
          ChatMessage(text: 'm1', sender: MessageSender.user),
          ChatMessage(text: 'm2', sender: MessageSender.ai),
          ChatMessage(text: 'm3', sender: MessageSender.user),
          ChatMessage(text: 'm4', sender: MessageSender.ai),
          ChatMessage(text: 'm5', sender: MessageSender.user),
          ChatMessage(text: 'm6', sender: MessageSender.ai),
          ChatMessage(text: 'm7', sender: MessageSender.user),
          ChatMessage(text: 'm8', sender: MessageSender.ai),
        ];

        final recentStart = conversation.length > AIConfig.maxContextMessages
            ? conversation.length - AIConfig.maxContextMessages
            : 0;

        final memory = SummaryMemory(
          summary: 'previous summary',
          summarizedCount: recentStart,
        );

        final newMessagesToSummarize = memory.summarizedCount < recentStart
            ? conversation.sublist(memory.summarizedCount, recentStart)
            : <ChatMessage>[];

        expect(recentStart, 3);
        expect(newMessagesToSummarize, isEmpty);
      },
    );

    test('summarizes only messages that have not already been included', () {
      final conversation = [
        ChatMessage(text: 'm1', sender: MessageSender.user),
        ChatMessage(text: 'm2', sender: MessageSender.ai),
        ChatMessage(text: 'm3', sender: MessageSender.user),
        ChatMessage(text: 'm4', sender: MessageSender.ai),
        ChatMessage(text: 'm5', sender: MessageSender.user),
        ChatMessage(text: 'm6', sender: MessageSender.ai),
        ChatMessage(text: 'm7', sender: MessageSender.user),
        ChatMessage(text: 'm8', sender: MessageSender.ai),
      ];

      final recentStart = conversation.length > AIConfig.maxContextMessages
          ? conversation.length - AIConfig.maxContextMessages
          : 0;

      final memory = SummaryMemory(
        summary: 'previous summary',
        summarizedCount: 1,
      );

      final newMessagesToSummarize = memory.summarizedCount < recentStart
          ? conversation.sublist(memory.summarizedCount, recentStart)
          : <ChatMessage>[];

      expect(recentStart, 3);
      expect(newMessagesToSummarize.map((message) => message.text).toList(), [
        'm2',
        'm3',
      ]);
    });
  });

  group('ConversationContextFactory', () {
    test(
      'keeps only the recent messages when there are more than the max window',
      () {
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
      },
    );

    test('keeps all messages when under the max window', () {
      final messages = [
        ChatMessage(text: 'm1', sender: MessageSender.user),
        ChatMessage(text: 'm2', sender: MessageSender.ai),
      ];

      final context = ConversationContextFactory.create(
        messages: messages,
        summary: 'short summary',
      );

      expect(context.summary, 'short summary');
      expect(context.recentMessages, messages);
    });
  });
}
