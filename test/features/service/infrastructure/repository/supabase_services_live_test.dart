// Live integration test: this hits your REAL Supabase project over the
// network using the credentials in .env. Run it explicitly, e.g.:
//   flutter test test/features/service/supabase_services_live_test.dart
//
// It is intentionally separate from the fast, offline unit tests so it
// doesn't slow down / break `flutter test` when there's no network access
// (e.g. in CI without secrets, or sandboxed environments).

import 'dart:convert';

import 'package:ai_assistant/core/config/env.dart';
import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/supabase_services_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// DIAGNOSTIC ONLY — prints every outgoing request/response.
class LoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('--- REQUEST (inside flutter test) ---');
    print('${request.method} ${request.url}');
    request.headers.forEach((k, v) => print('  $k: $v'));

    final response = await _inner.send(request);
    final bodyBytes = await response.stream.toBytes();

    print('--- RESPONSE ---');
    print('status: ${response.statusCode}');
    response.headers.forEach((k, v) => print('  $k: $v'));

    print('body: ${utf8.decode(bodyBytes)}');

    return http.StreamedResponse(
      Stream.value(bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: response.request,
    );
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
      debug: true,
    );

    print('URL: [${Env.supabaseUrl}]');
    print('KEY (first 12 chars): [${Env.supabaseAnonKey.substring(0, 12)}]');
    print('KEY length: ${Env.supabaseAnonKey.length}');
  });

  test('fetches real rows from the services table in Supabase', () async {
    final repository = SupabaseServicesRepository(
      client: Supabase.instance.client,
    );

    try {
      final List<Service> services = await repository.getServices();

      print('Fetched ${services.length} service(s) from Supabase.');

      for (final s in services) {
        print(' - ${s.id}: ${s.name} (\$${s.price}, ${s.durationMinutes}min)');
      }

      expect(services, isA<List<Service>>());
    } on PostgrestException catch (e, st) {
      print('========== POSTGREST ERROR ==========');
      print('message: ${e.message}');
      print('code: ${e.code}');
      print('details: ${e.details}');
      print('hint: ${e.hint}');
      print('stackTrace: $st');

      rethrow;
    }
  });

  // DIAGNOSTIC ONLY — bypasses Supabase.initialize()'s client entirely and
  // builds a raw SupabaseClient with logging, still inside flutter test's
  // TestWidgetsFlutterBinding, to see if the request itself looks different.
  test('DIAGNOSTIC: raw client with logging inside flutter test', () async {
    final rawClient = SupabaseClient(
      Env.supabaseUrl,
      Env.supabaseAnonKey,
      httpClient: LoggingClient(),
    );

    try {
      final rows = await rawClient.from('services').select();
      print('RAW CLIENT SUCCESS: $rows');
    } catch (e) {
      print('RAW CLIENT FAILED: $e');
    }
  });
}
