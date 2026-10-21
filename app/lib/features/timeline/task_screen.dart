import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/task_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// `/task/:id` (docs/07 shared): the task sheet as a page. The id is looked
/// up under the current user only; anything else reads "not here" (06 §9).
class TaskScreen extends StatelessWidget {
  const TaskScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Scaffold(
      key: ValueKey('route:task:$id'),
      appBar: AppBar(
        backgroundColor: c.surface,
        surfaceTintColor: c.surface,
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.today),
        ),
      ),
      body: SafeArea(child: TaskSheetBody(id: id)),
    );
  }
}
