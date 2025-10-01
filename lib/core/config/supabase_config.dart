import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static  String supabaseUrl = dotenv.env['SUPABASE_URL']!;

  static String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;


  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
