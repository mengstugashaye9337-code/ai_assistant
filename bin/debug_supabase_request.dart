import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
// Wraps the real http client and prints everything going in and out.
class LoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('--- REQUEST ---');
    print('${request.method} ${request.url}');
    request.headers.forEach((k, v) => print('  $k: $v'));

    final response = await _inner.send(request);
    final bodyBytes = await response.stream.toBytes();

    print('--- RESPONSE ---');
    print('status: ${response.statusCode}');
    response.headers.forEach((k, v) => print('  $k: $v'));
    print('body: ${utf8.decode(bodyBytes)}');

    // Rebuild the stream since we already consumed it above.
    return http.StreamedResponse(
      Stream.value(bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: response.request,
    );
  }
}

void main() async {
  final client = SupabaseClient(
    'https://qxysgsqnulgyolyuyxzf.supabase.co',
    'sb_publishable_Vq8wiHLj88jNs8FxiRkXVw_IBKeNsdr', // paste your real sb_publishable_... key
    httpClient: LoggingClient(),
  );

  try {
    final rows = await client.from('services').select();
    print('SUCCESS: $rows');
  } catch (e) {
    print('FAILED: $e');
  }
}
