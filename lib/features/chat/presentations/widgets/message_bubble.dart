import 'package:flutter/material.dart';
import 'package:ai_assistant/features/chat/domain/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(child: Text(message.text)),
    );
  }
}
