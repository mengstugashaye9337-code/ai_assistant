import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/chat_message.dart';

class GeminiChatMapper {
  static Content toGemini(ChatMessage message) {
    switch (message.sender) {
      case MessageSender.user:
        return Content.text(message.text);

      case MessageSender.ai:
        return Content("model", [TextPart(message.text)]);
    }
  }

  static ChatMessage fromGemini(GenerateContentResponse response,) {
    return ChatMessage(text: response.text ?? '', sender: MessageSender.ai);
  }
}
