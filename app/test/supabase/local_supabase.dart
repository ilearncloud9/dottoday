import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// The local stack (`supabase start`); CI exports its values.
final localUrl =
    Platform.environment['SUPABASE_URL'] ?? 'http://127.0.0.1:54321';
final localAnonKey =
    Platform.environment['SUPABASE_ANON_KEY'] ?? _anonFromCli();
final _mailpit =
    Platform.environment['MAILPIT_URL'] ?? 'http://127.0.0.1:54324';

String _anonFromCli() {
  final out = Process.runSync('supabase', ['status', '-o', 'json']);
  final status = jsonDecode(out.stdout as String) as Map<String, dynamic>;
  return status['ANON_KEY'] as String;
}

/// A client like the app's: PKCE, the verifier in memory.
SupabaseClient localClient() => SupabaseClient(
  localUrl,
  localAnonKey,
  authOptions: AuthClientOptions(pkceAsyncStorage: MemoryPkceStorage()),
);

final class MemoryPkceStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}

/// The sign-in link mailed to [email], followed one hop: where the server
/// redirects the browser (the app's callback with the code).
Future<Uri> magicLinkCallback(String email) async {
  final http = HttpClient();
  try {
    final link = await _waitForLink(http, email);
    final request = await http.getUrl(link)
      ..followRedirects = false;
    final response = await request.close();
    await response.drain<void>();
    return Uri.parse(response.headers.value(HttpHeaders.locationHeader)!);
  } finally {
    http.close();
  }
}

Future<Uri> _waitForLink(HttpClient http, String email) async {
  for (var i = 0; i < 50; i++) {
    final search = await _json(
      http,
      Uri.parse(
        '$_mailpit/api/v1/search?query=${Uri.encodeQueryComponent('to:"$email"')}',
      ),
    );
    final messages = search['messages'] as List<dynamic>;
    if (messages.isNotEmpty) {
      final id = (messages.first as Map<String, dynamic>)['ID'] as String;
      final message = await _json(
        http,
        Uri.parse('$_mailpit/api/v1/message/$id'),
      );
      final text = '${message['Text']} ${message['HTML']}';
      final match = RegExp(
        r'https?://[^\s"<>]+/auth/v1/verify\?[^\s"<>]+',
      ).firstMatch(text);
      return Uri.parse(match!.group(0)!.replaceAll('&amp;', '&'));
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  throw StateError('no sign-in mail for $email');
}

Future<Map<String, dynamic>> _json(HttpClient http, Uri uri) async {
  final response = await (await http.getUrl(uri)).close();
  return jsonDecode(await response.transform(utf8.decoder).join())
      as Map<String, dynamic>;
}
