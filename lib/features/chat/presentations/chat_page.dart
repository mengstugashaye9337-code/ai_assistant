import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/features/chat/applications/chat_notifier.dart';
import 'package:ai_assistant/features/chat/presentations/widgets/message_bubble.dart';
import 'package:ai_assistant/features/chat/presentations/widgets/message_input.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant")),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];

                return MessageBubble(message: message);
              },
            ),
          ),
          MessageInput(
            onSend: ref.read(chatNotifierProvider.notifier).sendMessage,
          ),
        ],
      ),
    );
  }
}
