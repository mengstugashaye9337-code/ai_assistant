import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ai_assistant/core/config/env.dart';

void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );

    supabase = Supabase.instance.client;
  });

  test('User A RLS test', () async {
    // 1. Authenticate User A

    // 2. Read conversations

    // 3. Verify User A can see their own conversation

    // 4. Verify User A cannot see User B's conversation
  });
}
