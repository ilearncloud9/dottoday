import 'package:flutter/material.dart';

// Minimal shell from M0.1 (docs/09). Theme, router and l10n replace this in
// M0.4–M0.6; bootstrap.dart takes over env loading in M0.3.
void main() {
  runApp(const DottodayApp());
}

/// Root widget. Intentionally blank until the M0 foundations land.
class DottodayApp extends StatelessWidget {
  const DottodayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(),
    );
  }
}
