import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/infrustructure/repository/groqmessage_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage', () {
    test('copyWith updates text and sender independently', () {
      const message = ChatMessage(text: 'Hello', sender: MessageSender.user);

      final updatedText = message.copyWith(text: 'Hi');
      expect(updatedText.text, 'Hi');
      expect(updatedText.sender, MessageSender.user);

      final updatedSender = message.copyWith(sender: MessageSender.ai);
      expect(updatedSender.text, 'Hello');
      expect(updatedSender.sender, MessageSender.ai);
    });

    test('serializes user messages for the chat API', () {
      final message = ChatMessage(text: 'Hello', sender: MessageSender.user);

      expect(GroqmessageMapper.toJson(message), {
        'role': 'user',
        'content': 'Hello',
      });
    });

    test('serializes AI messages for the chat API', () {
      final message = ChatMessage(text: 'Hi there', sender: MessageSender.ai);

      expect(GroqmessageMapper.toJson(message), {
        'role': 'assistant',
        'content': 'Hi there',
      });
    });
  });
}
