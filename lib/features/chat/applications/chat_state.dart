import 'package:ai_assistant/features/chat/domain/chat_message.dart';

//enum ChatStatus { streaming, idle, error }

sealed class ChatStatus {
  const ChatStatus();
}

class Streaming extends ChatStatus {
  const Streaming();
}

class Idle extends ChatStatus {
  const Idle();
}

class ChatError extends ChatStatus {
  const ChatError();
}

class ChatState {
  final List<ChatMessage> messages;
  final ChatStatus status;
  final String? conversationId;

  const ChatState({
    required this.messages,
    required this.status,
    this.conversationId,
  });
  factory ChatState.initial() {
    return const ChatState(messages: [], status: Idle(), conversationId: null);
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    String? conversationId,
    bool clearConversationId = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      conversationId: clearConversationId
          ? null
          : (conversationId ?? this.conversationId),
    );
  }
}
