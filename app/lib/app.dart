import 'package:dottoday/core/router/router_provider.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget: theme + router. Shell UI lands in M0.13, l10n in M0.6.
class DottodayApp extends ConsumerWidget {
  const DottodayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
