import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Root widget. Themed and otherwise blank until router (M0.5) and l10n
/// (M0.6) land.
class DottodayApp extends StatelessWidget {
  const DottodayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const Scaffold(),
    );
  }
}
