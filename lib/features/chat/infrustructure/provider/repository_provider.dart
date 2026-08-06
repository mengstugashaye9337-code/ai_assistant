import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/chat/infrustructure/repository/groq_repository.dart';
import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/infrustructure/services/groq_provider.dart';
import 'package:ai_assistant/features/chat/infrustructure/repository/conversation_builder.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final client = ref.watch(groqClientProvider);
  final builder = ConversationBuilder();
  return GroqRepository(client: client, builder: builder);
});
