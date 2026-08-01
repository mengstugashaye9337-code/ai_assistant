import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage', () {
    test('serializes user messages for the chat API', () {
      final message = ChatMessage(text: 'Hello', sender: MessageSender.user);

      expect(message.toJson(), {'role': 'user', 'content': 'Hello'});
    });

    test('serializes AI messages for the chat API', () {
      final message = ChatMessage(text: 'Hi there', sender: MessageSender.ai);

      expect(message.toJson(), {'role': 'assistant', 'content': 'Hi there'});
    });
  });
}
