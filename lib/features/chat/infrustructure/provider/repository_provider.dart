import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/chat/infrustructure/groq_repository.dart';
import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/infrustructure/provider/groq_provider.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final client = ref.watch(groqClientProvider);
  return GroqRepositroy(client: client);
});
