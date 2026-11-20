import 'dart:async';

import 'package:dottoday/core/editing/add_anchor.dart';
import 'package:dottoday/core/editing/add_modes.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/features/task_editor/add/add_minimal_what.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/add_when_host.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:dottoday/features/task_editor/add/popover/add_popover.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_header.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sheets/side_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens Add (docs/10 §3 `AddFlow`) from the add button or ⌘N, on its
/// [mode]'s tab: Create task on phones (ED-140); on tablets Create task
/// in a popover under the + on iPad and in a modal side sheet on Android
/// (E-R2-3, ED-271); the popover under the toolbar's + on the Mac and the
/// web from medium width (E-R2-36, ED-342); and Minimal's own Add sheet at
/// every width (ED-152, M19.6). [text] prefills the title, [startUtc] the
/// time and [day] the day; [resume] reopens Add whose save failed, as it
/// was (M8.5b).
Future<void> showAddFlow(
  BuildContext context, {
  String text = '',
  DateTime? startUtc,
  DateTime? day,
  AddFlowState? resume,
  AddMode mode = AddMode.task,
}) {
  final request = AddRequest(
    languageCode: Localizations.localeOf(context).languageCode,
    text: text,
    startUtc: startUtc,
    day: day,
    resume: resume,
  );
  Widget create(BuildContext _) =>
      CreateTaskSheet(request: request, mode: mode);
  return switch (_hostOf(context)) {
    // Sized to its content over the keyboard (E-PhonesMinimal frame 3).
    _AddHost.minimal => showAppSheet<void>(
      context: context,
      // Its form scrolls and its foot stays in view above the keyboard.
      scrolls: false,
      builder: (_) => AddFlowSheet(request: request),
    ),
    _AddHost.phone => showAppSheet<void>(
      context: context,
      fullHeight: true,
      builder: create,
    ),
    _AddHost.ipad => showAnchoredPopover<void>(
      context: context,
      anchor: AddAnchor.current(),
      width: DotSize.tabletAddWidth,
      height: DotSize.tabletAddHeight,
      radius: DotRadii.tabletPopover,
      arrow: false,
      builder: create,
    ),
    _AddHost.androidTablet => showModalSideSheet<void>(
      context: context,
      builder: create,
    ),
    _AddHost.popover => showAnchoredPopover<void>(
      context: context,
      anchor: AddAnchor.current(),
      width: DotSize.addPopover,
      builder: (_) => AddPopover(request: request, mode: mode),
    ),
  };
}

/// Where Add opens: by width class, then the platform's container
/// (docs/10 §4 lets containers differ by platform; layout never does).
enum _AddHost { minimal, phone, ipad, androidTablet, popover }

_AddHost _hostOf(BuildContext context) {
  final minimal =
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(layoutPolicyProvider).visibility(FeatureId.addTask) ==
      FeatureVisibility.simplified;
  if (minimal) return _AddHost.minimal;
  // AppLayout: a short landscape phone stays compact too (H1).
  if (AppLayout.classOf(context) == WidthClass.compact) return _AddHost.phone;
  if (webChrome(context)) return _AddHost.popover;
  return switch (Theme.of(context).platform) {
    TargetPlatform.iOS => _AddHost.ipad,
    TargetPlatform.android => _AddHost.androidTablet,
    _ => _AddHost.popover,
  };
}

/// Minimal's Add sheet (docs/14 §4, ED-152; M19.6 part 6d-2): What and
/// when ([AddMinimalWhat]), sized to its content as drawn, then When.
class AddFlowSheet extends ConsumerWidget {
  const AddFlowSheet({required this.request, super.key});

  final AddRequest request;

  /// The When step's share of the window (a near-full sheet).
  static const _whenShare = 0.85;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addFlowProvider(request)).value;
    if (state == null) return const SizedBox.shrink();
    final notifier = ref.read(addFlowProvider(request).notifier);
    final what = state.step == AddStep.what;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // What has its own nav bar or title (E-PhonesMinimal frames 3, 6).
        if (!what)
          AddHeader(
            step: state.step,
            onBack: () => notifier.goTo(AddStep.what),
          ),
        if (state.saveFailure case final failed?)
          SaveFailureBanner(
            failure: failed.failure,
            onRetry: () => _retry(context, ref, state, failed.retry),
          ),
        if (what)
          Flexible(
            child: AddMinimalWhat(request: request, state: state),
          )
        else
          // The When step asks for most of the window and takes what the
          // content-sized sheet has.
          Flexible(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * _whenShare,
              child: AddWhenHost(request: request, state: state),
            ),
          ),
      ],
    );
  }

  /// Try again: the same save, with the draft as it is now.
  void _retry(
    BuildContext context,
    WidgetRef ref,
    AddFlowState state,
    AddRetry retry,
  ) {
    final draft = currentDraft(ref, request, state);
    unawaited(switch (retry) {
      AddRetry.save => saveFromSheet(context, request, draft),
      AddRetry.inbox => saveFromSheet(context, request, draft, toInbox: true),
      AddRetry.another => addAnother(context, request, draft),
      AddRetry.many => addManyFromSheet(context, request, state.text),
    });
  }
}
