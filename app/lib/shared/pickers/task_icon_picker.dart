import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart' show ColourDot;
import 'package:dottoday/shared/pickers/task_icon_grid.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// What the full picker returns: the colour (unchanged when only an icon
/// was picked) and the icon.
typedef TaskLook = ({TaskColor color, TaskIcon icon});

/// The full colour and icon picker (docs/10 §5.3 "Colour & icon full
/// picker"): every colour, a search field, then the icon library by
/// category. Tapping an icon picks it with the colour shown; "Done" keeps
/// the icon and takes the colour alone. Full height: a tall sheet on
/// phones, a tall popover from medium width.
Future<TaskLook?> showTaskLookPicker({
  required BuildContext context,
  required TaskColor colour,
  required TaskIcon icon,
}) => showAppSheet<TaskLook>(
  context: context,
  fullHeight: true,
  builder: (_) => _PickerSheet(
    title: context.l10n.colourIconTitle,
    colour: colour,
    icon: icon,
    chooseColour: true,
  ),
);

/// The icon library alone (the Search screen's "with icon" filter).
Future<TaskIcon?> showTaskIconPicker({
  required BuildContext context,
  required String title,
}) async {
  final picked = await showAppSheet<TaskLook>(
    context: context,
    fullHeight: true,
    builder: (_) => _PickerSheet(
      title: title,
      colour: TaskColor.fallback,
      icon: TaskIcon.fallback,
      chooseColour: false,
    ),
  );
  return picked?.icon;
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.colour,
    required this.icon,
    required this.chooseColour,
  });

  final String title;
  final TaskColor colour;
  final TaskIcon icon;
  final bool chooseColour;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

/// A leaf: the colour and search text while choosing.
class _PickerSheetState extends State<_PickerSheet> {
  late var _colour = widget.colour;
  var _query = '';

  void _pop(TaskIcon icon) =>
      Navigator.of(context).pop<TaskLook>((color: _colour, icon: icon));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: DotSpace.l,
        end: DotSpace.l,
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          _Header(title: widget.title),
          if (widget.chooseColour)
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (final c in TaskColor.values)
                  ColourDot(
                    colour: c,
                    selected: c == _colour,
                    onTap: () => setState(() => _colour = c),
                  ),
              ],
            ),
          _SearchField(onChanged: (q) => setState(() => _query = q)),
          Expanded(
            child: TaskIconGrid(
              query: _query,
              colour: widget.chooseColour ? _colour : null,
              selected: widget.chooseColour ? widget.icon : null,
              onPick: _pop,
            ),
          ),
          if (widget.chooseColour)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: DotSpace.l),
              // A colour alone is a choice too.
              child: FilledButton(
                onPressed: () => _pop(widget.icon),
                child: Text(l10n.colourIconDone),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: DotSpace.s),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: t.styles.cardTitle),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: context.l10n.sheetClose,
            icon: DotIcon(DotGlyphs.close, color: t.colors.muted),
          ),
        ],
      ),
    );
  }
}

/// A leaf: owns its controller.
class _SearchField extends StatefulWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return TextField(
      controller: _controller,
      style: t.styles.rowTitle,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: context.l10n.iconSearchHint,
        filled: true,
        fillColor: t.colors.raised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DotRadii.cardLarge),
          borderSide: BorderSide(color: t.colors.outline),
        ),
        prefixIcon: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: DotIcon(
            DotGlyphs.search,
            color: t.colors.accentInk,
            size: DotSize.rowIcon + DotSpace.xxs,
          ),
        ),
      ),
    );
  }
}
