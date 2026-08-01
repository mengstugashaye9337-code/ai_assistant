import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/features/chat/infrustructure/groq_service.dart';
import 'package:ai_assistant/core/config/env.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.groq.com', // Add the base URL
      headers: {
        'Authorization': 'Bearer ${Env.groqApiKey}', // Inject your API Key
        'Content-Type': 'application/json',
      },
    ),
  );
});

final groqClientProvider = Provider<GroqClient>((ref) {
  final dio = ref.watch(dioProvider);
  return GroqClient(dio: dio);
});
