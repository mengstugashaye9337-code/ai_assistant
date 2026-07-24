enum MessageSender { user, ai }

class ChatMessage {
  final String text;
  final MessageSender sender;

  const ChatMessage({required this.text, required this.sender});

  ChatMessage copyWith({
    String? text, 
    MessageSender? sender}) {
    return ChatMessage(
      text: text ?? this.text, 
      sender: sender ?? this.sender);
  }
}
