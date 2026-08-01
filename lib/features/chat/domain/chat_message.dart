enum MessageSender { user, ai }

class ChatMessage {
  final String text;
  final MessageSender sender;

  const ChatMessage({required this.text, required this.sender});

  Map<String, dynamic> toJson() {
    return {
      'role': sender == MessageSender.ai ? 'assistant' : 'user',
      'content': text,
    };
  }

  ChatMessage copyWith({String? text, MessageSender? sender}) {
    return ChatMessage(text: text ?? this.text, sender: sender ?? this.sender);
  }
}
