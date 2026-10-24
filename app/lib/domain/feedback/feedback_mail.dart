/// The feedback draft (PRD F11, R-19): subject with the app version, and —
/// only when the user opts in — the `diagnostics.json` block in the body
/// (`FeedbackDiagnostics.toText`). A `mailto:` link can't attach a file, so
/// the block goes in the body, where the person sees it before sending.
/// Never task content (06 §5).
///
/// ```dart
/// feedbackMailto(version: '0.1.0 (1)', platform: 'iOS', subject: 'Dottoday feedback');
/// ```
Uri feedbackMailto({
  required String subject,
  required String version,
  required String platform,
  String? recipient,
  String? diagnostics,
}) => Uri(
  scheme: 'mailto',
  path: recipient ?? '',
  query: _encode({
    'subject': '$subject ($version, $platform)',
    if (diagnostics != null)
      'body': '\n\n--- diagnostics.json ---\n$diagnostics',
  }),
);

// mailto wants %20, not +, for spaces (RFC 6068).
String _encode(Map<String, String> params) => params.entries
    .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
    .join('&');

/// The platform as the feedback subject names it: `web`, else the target
/// (`iOS`, `android`, `macOS` …).
String feedbackPlatform({required bool web, required String target}) =>
    web ? 'web' : target;
