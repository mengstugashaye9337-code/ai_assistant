import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ai_assistant/core/config/env.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  });

  test('connects to Supabase', () async {
    final supabase = Supabase.instance.client;

    expect(supabase, isNotNull);

    print('Supabase client initialized successfully');
  });
}
