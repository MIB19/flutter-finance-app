import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App configuration, loaded from a `.env` file (see `.env.example`).
/// `dotenv.load()` is called in main() before these are read.
class Env {
  static String _get(String key, [String fallback = '']) =>
      (dotenv.isInitialized ? dotenv.env[key] : null) ?? fallback;

  static String get apiBaseUrl => _get('API_BASE_URL', 'http://10.0.2.2:4000');
  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');
  static String get googleWebClientId => _get('GOOGLE_WEB_CLIENT_ID');
}
