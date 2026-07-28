import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY']!;

  static String get supabaseUrl => dotenv.env['MY_SUPABASE_URL']!;

  static String get supabaseAnonKey => dotenv.env['MY_SUPABASE_ANON_KEY']!;
}
