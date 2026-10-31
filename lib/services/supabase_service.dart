import 'package:supabase_flutter/supabase_flutter.dart';

/// Tempo máximo de espera por qualquer chamada ao servidor.
const limiteRede = Duration(seconds: 15);

class SupabaseService {
  static SupabaseClient get client {
    return Supabase.instance.client;
  }
}