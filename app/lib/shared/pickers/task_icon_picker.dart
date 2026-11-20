import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/task_icon_grid.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// A task's colour and icon as one value (the colour and icon pickers,
/// M19.4 part 4c).
typedef TaskLook = ({TaskColor color, TaskIcon icon});

/// The icon library alone (the Search screen's "with icon" filter).
Future<TaskIcon?> showTaskIconPicker({
  required BuildContext context,
  required String title,
}) => showAppSheet<TaskIcon>(
  context: context,
  fullHeight: true,
  builder: (_) => _PickerSheet(title: title),
);

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({required this.title});

  final String title;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

/// A leaf: the search text.
class _PickerSheetState extends State<_PickerSheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
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
          _SearchField(onChanged: (q) => setState(() => _query = q)),
          Expanded(
            child: TaskIconGrid(
              query: _query,
              colour: null,
              selected: null,
              onPick: (i) => Navigator.of(context).pop(i),
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
