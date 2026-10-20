import 'package:flutter/material.dart';

/// Root widget. Intentionally blank until theme (M0.4), router (M0.5) and
/// l10n (M0.6) land.
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
