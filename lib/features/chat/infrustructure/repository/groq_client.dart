import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class GroqClient {
  final Dio dio;

  GroqClient({required this.dio});

  static const _chatEndpoint = '/openai/v1/chat/completions';

  Stream<String> chat(Map<String, dynamic> requestBody) async* {
    try {
      final response = await dio.post<ResponseBody>(
        _chatEndpoint,
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;

      if (stream == null) {
        throw Exception('No stream available');
      }

      await for (final Uint8List chunk in stream) {
        final chunkString = utf8.decode(chunk);

        final lines = chunkString.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ') && !line.contains('[DONE]')) {
            try {
              final jsonStr = line.substring(6);
              final json = jsonDecode(jsonStr);

              final content = json['choices']?[0]?['delta']?['content'];

              if (content != null) {
                yield content;
              }
            } catch (_) {
              // Ignore incomplete JSON chunks.
            }
          }
        }
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
