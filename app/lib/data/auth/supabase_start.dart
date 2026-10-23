import 'package:dottoday/core/env/env.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/auth/auth_vault.dart';
import 'package:dottoday/data/auth/session_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Starts Supabase for accounts and sync (docs/09 M6.1): PKCE, the session
/// and verifier in the [AuthVault] (06 §2). Only the web reads the
/// sign-in code from its own address; the apps get it through the router
/// (`dottoday://auth-callback`), the one path for every link (M5.0).
///
/// Null when it can't start: the app is whole without an account (02 F7).
Future<SupabaseClient?> startSupabase(Env env, Logger logger) async {
  try {
    final vault = platformAuthVault();
    final supabase = await Supabase.initialize(
      url: env.supabaseUrl.toString(),
      // The anon key: publishable, never the service role (06 §1).
      publishableKey: env.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: VaultSessionStorage(vault),
        pkceAsyncStorage: VaultPkceStorage(vault),
        detectSessionInUri: kIsWeb,
      ),
    );
    return supabase.client;
  } on Object catch (e, s) {
    logger.error('supabase.start_failed', error: e, stackTrace: s);
    return null;
  }
}
