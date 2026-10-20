import 'package:dottoday/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to a blank scaffold', (tester) async {
    await tester.pumpWidget(const DottodayApp());

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
