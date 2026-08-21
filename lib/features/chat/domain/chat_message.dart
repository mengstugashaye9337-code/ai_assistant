enum MessageSender { user, ai }

class ChatMessage {
  final String? id;
  final String text;
  final MessageSender sender;

  const ChatMessage({required this.text, required this.sender, this.id});

  ChatMessage copyWith({String? text, MessageSender? sender, String? id}) {
    return ChatMessage(
      text: text ?? this.text,
      sender: sender ?? this.sender,
      id: id ?? this.id,
    );
  }
}
