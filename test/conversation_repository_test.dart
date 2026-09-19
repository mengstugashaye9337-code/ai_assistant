import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/message_repository.dart';
//import 'package:ai_assistant/features/chat/infrustructure/repository/supabase_conversation_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    if (!Supabase.instance.isInitialized) {
      Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'example-anon-key',
      );
    }
  });

  test('SupabaseConversationRepository implements the domain contract', () {
    final repository = SupabaseConversationRepository(
      client: Supabase.instance.client,
    );

    expect(repository, isA<ConversationRepository>());
    expect(
      repository.getMessages('conversation-1'),
      isA<Future<List<ChatMessage>>>(),
    );
  });
}
