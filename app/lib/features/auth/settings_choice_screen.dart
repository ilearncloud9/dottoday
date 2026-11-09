import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/l10n/language_names.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/layout/layout_policy.dart';
import 'package:dottoday/domain/profile/settings_difference.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/time_zones.dart';
import 'package:dottoday/shared/account/account_buttons.dart';
import 'package:dottoday/shared/account/choice_card.dart';
import 'package:dottoday/shared/account/decision_frame.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// B1 (CR-160 criterion 7, board `SettingsChoice`): the account already
/// had settings and this device had different ones when it signed in.
/// Shows only the rows that differ; the account's stay unless the person
/// picks the device's. "Decide later" keeps the device's for Settings ›
/// Account.
class SettingsChoiceScreen extends ConsumerStatefulWidget {
  const SettingsChoiceScreen({required this.gate, super.key});

  final SettingsChoiceGate gate;

  @override
  ConsumerState<SettingsChoiceScreen> createState() =>
      _SettingsChoiceScreenState();
}

/// A leaf: the choice, the request in flight and its error.
class _SettingsChoiceScreenState extends ConsumerState<SettingsChoiceScreen> {
  var _device = false;
  var _busy = false;
  String? _error;

  Future<void> _go(Future<void> Function(AccountActions a) op) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await op(ref.read(accountActionsProvider));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continue(AccountActions a) async {
    final account = widget.gate.account;
    if (!_device) return a.keepAccountSettings(account.id);
    final l10n = context.l10n;
    final result = await a.useDeviceSettings(account);
    if (result case Err(:final failure) when mounted) {
      setState(() => _error = failureMessage(l10n, failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gate = widget.gate;
    return DecisionFrame(
      title: l10n.settingsChoiceTitle,
      body: l10n.settingsChoiceBody,
      content: [
        Semantics(
          label: l10n.settingsChoiceLegend,
          explicitChildNodes: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.m,
            children: [
              ChoiceCard(
                title: l10n.settingsChoiceAccount,
                selected: !_device,
                onTap: () => setState(() => _device = false),
                children: [_Rows(profile: gate.account, fields: gate.fields)],
              ),
              ChoiceCard(
                title: l10n.settingsChoiceDevice,
                selected: _device,
                onTap: () => setState(() => _device = true),
                children: [_Rows(profile: gate.device, fields: gate.fields)],
              ),
            ],
          ),
        ),
        DecisionNote(l10n.settingsChoiceOnlyDiffer),
        if (_error case final error?) StatusLine(error),
      ],
      actions: [
        FilledButton(
          onPressed: _busy ? null : () => unawaited(_go(_continue)),
          child: Text(l10n.accountContinue),
        ),
        TextButton(
          onPressed: _busy
              ? null
              : () => unawaited(
                  _go(
                    (a) => a.decideSettingsLater(gate.account.id, later: true),
                  ),
                ),
          child: Text(l10n.settingsChoiceLater),
        ),
        DecisionNote(l10n.settingsChoiceLaterHint, centred: true),
      ],
    );
  }
}

/// The differing [fields] of [profile]: a label column and the values.
class _Rows extends StatelessWidget {
  const _Rows({required this.profile, required this.fields});

  final Profile profile;
  final List<SettingsField> fields;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final label = t.styles.body.copyWith(color: t.colors.muted);
    return Padding(
      padding: const EdgeInsets.only(top: DotSpace.s),
      child: Table(
        columnWidths: const {0: IntrinsicColumnWidth()},
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          for (final f in fields)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: DotSpace.l,
                    bottom: DotSpace.s,
                  ),
                  child: Text(_label(context, f), style: label),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: DotSpace.s),
                  child: Text(_value(context, f), style: t.styles.body),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _label(BuildContext context, SettingsField f) {
    final l10n = context.l10n;
    return switch (f) {
      SettingsField.timeZone => l10n.settingsChoiceTimeZone,
      SettingsField.language => l10n.settingsLanguage,
      SettingsField.yourDay => l10n.settingsChoiceYourDay,
      SettingsField.layout => l10n.layoutRow,
      SettingsField.theme => l10n.settingsTheme,
    };
  }

  String _value(BuildContext context, SettingsField f) {
    final l10n = context.l10n;
    final s = profile.settings;
    return switch (f) {
      SettingsField.timeZone => zoneCity(profile.tzId),
      SettingsField.language => languageName(profile.locale),
      SettingsField.yourDay => _window(context, s),
      SettingsField.layout =>
        LayoutPolicy.forSettings(s).isMinimal
            ? l10n.layoutMinimal
            : l10n.layoutFull,
      SettingsField.theme => switch (s.theme) {
        ThemePreference.system => l10n.settingsThemeSystem,
        ThemePreference.light => l10n.settingsThemeLight,
        ThemePreference.dark => l10n.settingsThemeDark,
      },
    };
  }

  /// "7:00 AM – 11:00 PM": the everyday Wake Up to Wind Down.
  String _window(BuildContext context, Settings s) {
    final w = commonWindow(s);
    String at(String hhmm) => formatClockTime(
      context,
      ClockTime.fromMinutes(windowMinutes(hhmm)),
      use24h: s.use24h,
    );
    return context.l10n.settingsChoiceRange(at(w.start), at(w.end));
  }
}
