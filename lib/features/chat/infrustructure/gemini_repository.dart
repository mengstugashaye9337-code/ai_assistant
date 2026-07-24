import 'package:ai_assistant/features/chat/domain/chat_message.dart';
import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
//import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
import 'package:ai_assistant/features/chat/infrustructure/gemini_maper.dart';

class GeminiRepository implements AIRepository {
  final GenerativeModel _model;

  GeminiRepository({required GenerativeModel model}) : _model = model;

  @override
  Stream<String> sendMessage(List<ChatMessage> messages) async* {
    final contents = messages.map(GeminiChatMapper.toGemini).toList();
    final stream = _model.generateContentStream(contents);

    await for (final response in stream) {
      final text = response.text;

      if (text != null && text.isNotEmpty) {
        yield text;
      }
    }
  }
}
