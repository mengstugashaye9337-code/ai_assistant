import 'package:ai_assistant/core/config/env.dart';
//import 'package:ai_assistant/features/chat/domain/ai_repository.dart';
//import 'package:ai_assistant/features/chat/infrustructure/gemini_repository.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final geminiProvider = Provider<GenerativeModel>((ref) {
  return GenerativeModel(model: 'gemini-1.5-flash', apiKey: Env.geminiApiKey);
});
