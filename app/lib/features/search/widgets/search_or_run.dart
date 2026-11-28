import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/search/state/search_state.dart';
import 'package:dottoday/features/search/widgets/search_or_run_rows.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Most tasks the palette lists; Search shows them all.
const _maxTasks = 5;

/// Search or run (ED-333, E-R2-30; docs/14 `searchOrRun`): ⌘K / Ctrl K
/// or the web's k, and the toolbar's "Search or run". A field over the
/// tasks that match, then the commands that match ([commands], the app's
/// own menus, so the palette and the menu bar run the same handlers),
/// with "Search for …" first. ↑↓ move, ↵ opens, Esc or a click outside
/// closes; it adds no history (ED-242). Minimal's is the Everything else
/// finder: its own menus, under [placeholder].
Future<void> showSearchOrRun(
  BuildContext context, {
  required List<PaletteCommand> commands,
  required String placeholder,
}) {
  final motion = DotTheme.of(context).motion;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: motion.fast,
    transitionBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    // The host's providers, wherever the dialog route sits.
    pageBuilder: (_, _, _) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context, listen: false),
      child: SearchOrRun(
        host: context,
        commands: commands,
        placeholder: placeholder,
      ),
    ),
  );
}

/// The palette's panel. [host] (still mounted after the palette closes)
/// opens a task or Search.
class SearchOrRun extends ConsumerStatefulWidget {
  const SearchOrRun({
    required this.host,
    required this.commands,
    required this.placeholder,
    super.key,
  });

  final BuildContext host;
  final List<PaletteCommand> commands;
  final String placeholder;

  @override
  ConsumerState<SearchOrRun> createState() => _SearchOrRunState();
}

class _SearchOrRunState extends ConsumerState<SearchOrRun> {
  final _field = TextEditingController();
  late final _focus = FocusNode(onKeyEvent: _key);

  /// The highlighted row, across tasks then commands.
  int _at = 0;
  List<PaletteItem> _items = const [];

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _key(FocusNode node, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final n = _items.length;
    switch (e.logicalKey) {
      case LogicalKeyboardKey.arrowDown when n > 0:
        setState(() => _at = (_at + 1) % n);
      case LogicalKeyboardKey.arrowUp when n > 0:
        setState(() => _at = (_at - 1 + n) % n);
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.numpadEnter:
        if (n > 0) _run(_items[_at.clamp(0, n - 1)]);
      case LogicalKeyboardKey.escape:
        Navigator.of(context).pop();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// Closes the palette, then does what [item] says.
  void _run(PaletteItem item) {
    Navigator.of(context).pop();
    final host = widget.host;
    switch (item) {
      case PaletteTask(:final task):
        if (host.mounted) openTask(host, task.id);
      // After the palette has gone, so a command that asks the focused
      // screen (Previous Day, Copy Day as Text) reaches that screen.
      case PaletteRun(:final command):
        WidgetsBinding.instance.addPostFrameCallback((_) => command.run());
    }
  }

  /// "Search for …": Search with what was typed, set once Search is on
  /// screen (its input lives while Search watches it).
  void _searchFor(String query) {
    final host = widget.host;
    if (!host.mounted) return;
    final container = ProviderScope.containerOf(host, listen: false);
    GoRouter.of(host).go(AppRoutes.search);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => container.read(searchInputStateProvider.notifier).type(query),
    );
  }

  List<PaletteItem> _build(String query) {
    final l10n = context.l10n;
    final q = query.toLowerCase();
    final List<Occurrence> tasks = q.isEmpty
        ? const []
        : (ref.watch(searchHitsProvider(query)).value ?? const [])
              .take(_maxTasks)
              .toList();
    return [
      for (final t in tasks) PaletteTask(t),
      if (q.isNotEmpty)
        PaletteRun(
          PaletteCommand(
            l10n.paletteSearchFor(query),
            () => _searchFor(query),
            search: true,
          ),
        ),
      for (final c in widget.commands)
        if (c.label.toLowerCase().contains(q)) PaletteRun(c),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final query = _field.text.trim();
    _items = _build(query);
    final at = _items.isEmpty ? 0 : _at.clamp(0, _items.length - 1);
    final height = MediaQuery.sizeOf(context).height;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: height / 8,
          left: DotSpace.l,
          right: DotSpace.l,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: DotSize.palette,
            maxHeight: height * 3 / 4,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.card,
              borderRadius: BorderRadius.circular(DotRadii.card),
              border: Border.all(color: t.colors.threadAhead),
              boxShadow: DotElevation.floating,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _input(t),
                  Divider(height: 1, color: t.colors.threadAhead),
                  Flexible(
                    child: PaletteList(
                      items: _items,
                      at: at,
                      query: query,
                      onHover: (i) => setState(() => _at = i),
                      onRun: _run,
                    ),
                  ),
                  const PaletteFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(DotTheme t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
    child: Row(
      spacing: DotSpace.s,
      children: [
        DotIcon(
          DotGlyphs.search,
          color: t.colors.secondary,
          size: DotSize.rowIcon,
        ),
        Expanded(
          child: TextField(
            contextMenuBuilder: systemTextMenu,
            controller: _field,
            focusNode: _focus,
            autofocus: true,
            style: t.styles.body,
            autocorrect: false,
            onChanged: (_) => setState(() => _at = 0),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: t.styles.body.copyWith(color: t.colors.secondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ),
      ],
    ),
  );
}
