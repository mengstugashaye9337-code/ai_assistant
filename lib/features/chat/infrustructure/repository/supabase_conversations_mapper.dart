import 'package:ai_assistant/features/chat/domain/conversation.dart';
import 'package:ai_assistant/features/chat/domain/conversation_repository.dart';

class SupabaseConversationsMapper {
  static Conversation fromSupabase(Map<String, dynamic> row) {
    return Conversation(
      id: row['id'] as String?,
      userId: row['user_id'] as String,
      title: row['title'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toSupabase(Conversation conversation) {
    return {'title': conversation.title, 'user_id': conversation.userId};
  }
}
