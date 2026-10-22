import 'package:dottoday/domain/feedback/feedback_mail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no recipient, version and platform in the subject', () {
    final uri = feedbackMailto(
      subject: 'Dottoday feedback',
      version: '0.1.0 (1)',
      platform: 'iOS',
    );
    expect(uri.scheme, 'mailto');
    expect(uri.path, '');
    expect(
      uri.toString(),
      contains('subject=Dottoday%20feedback%20(0.1.0%20(1)%2C%20iOS)'),
    );
    expect(uri.toString(), isNot(contains('body')));
  });

  test('diagnostics only when given; a recipient when configured', () {
    final uri = feedbackMailto(
      subject: 'Feedback',
      version: '0.1.0',
      platform: 'web',
      recipient: 'team@example.com',
      diagnostics: 'Version 0.1.0\nPlatform web',
    );
    expect(uri.path, 'team@example.com');
    expect(Uri.decodeComponent(uri.query), contains('Platform web'));
  });
}
