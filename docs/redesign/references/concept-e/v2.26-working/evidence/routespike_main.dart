// Throwaway spike (CR-068): hash URLs with ?task= on go_router 18.1.1 —
// refresh and browser Back / Forward. Synthetic data only.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(path: '/today', builder: (c, s) => Page(view: 'today', task: s.uri.queryParameters['task'])),
    GoRoute(path: '/day/:date', builder: (c, s) => Page(view: 'day ${s.pathParameters['date']}', task: s.uri.queryParameters['task'])),
    GoRoute(path: '/task/:id', redirect: (c, s) => '/today?task=${s.pathParameters['id']}'),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  SemanticsBinding.instance.ensureSemantics();
  runApp(MaterialApp.router(routerConfig: router));
}

class Page extends StatelessWidget {
  const Page({super.key, required this.view, this.task});
  final String view;
  final String? task;
  @override
  Widget build(BuildContext context) {
    final here = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: Column(children: [
        Text('VIEW=$view TASK=${task ?? '-'} LOC=$here', key: const Key('state')),
        TextButton(onPressed: () => context.push('/today?task=t1'), child: const Text('open t1')),
        TextButton(onPressed: () => context.go('/today'), child: const Text('close')),
        TextButton(onPressed: () => context.push('/day/2026-11-04'), child: const Text('next day')),
      ]),
    );
  }
}
