import 'package:ai_assistant/core/config/const.dart';
;

class AIConfig {
  static const model = AIModels.llama33;
  static const stream = true;
  static const maxContextMessages = 20;
  static const temperature = 0.7;
  static const instruction =
      'You are a helpful assistant. Answer the questions as best you can. You have access to the following tools:';
  static const String summaryInstruction = '''
You are a conversation summarizer.

Summarize the following conversation.

Preserve:
- names
- goals
- preferences
- unfinished tasks

Remove:
- greetings
- repetition
- filler.
-Return only the summarized conversation.
Do not answer the conversation.
''';
}
