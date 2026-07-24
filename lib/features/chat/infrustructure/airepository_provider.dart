import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/chat/infrustructure/gemini_provider.dart';
import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/infrustructure/gemini_repository.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final model = ref.watch(geminiProvider);
  return GeminiRepository(model: model);
});
