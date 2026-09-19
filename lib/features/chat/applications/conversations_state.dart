import 'package:ai_assistant/features/chat/domain/conversation.dart';

sealed class ConversationsStatus {
  const ConversationsStatus();
}

class ConversationsLoading extends ConversationsStatus {
  const ConversationsLoading();
}

class ConversationsIdle extends ConversationsStatus {
  const ConversationsIdle();
}

class ConversationsError extends ConversationsStatus {
  const ConversationsError();
}

class ConversationsState {
  final List<Conversation> conversations;
  final ConversationsStatus status;

  const ConversationsState({required this.conversations, required this.status});

  factory ConversationsState.initial() {
    return const ConversationsState(
      conversations: [],
      status: ConversationsIdle(),
    );
  }

  ConversationsState copyWith({
    List<Conversation>? conversations,
    ConversationsStatus? status,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      status: status ?? this.status,
    );
  }
}
