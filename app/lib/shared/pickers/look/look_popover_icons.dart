import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/look/look_icons.dart';
import 'package:dottoday/shared/pickers/look/look_library.dart';
import 'package:dottoday/shared/pickers/look/look_parts.dart';
import 'package:flutter/material.dart';

/// All icons… inside the Mac and web popover (owner, 4c-3): Back, the
/// search field, and the library at the popover's size; a pick returns.
class LookPopoverIcons extends StatefulWidget {
  const LookPopoverIcons({
    required this.colour,
    required this.icon,
    required this.recent,
    required this.onIcon,
    required this.onBack,
    super.key,
  });

  final TaskColor colour;
  final TaskIcon icon;
  final List<TaskIcon> recent;
  final ValueChanged<TaskIcon> onIcon;
  final VoidCallback onBack;

  @override
  State<LookPopoverIcons> createState() => _LookPopoverIconsState();
}

/// A leaf: the search text and the library's scroll.
class _LookPopoverIconsState extends State<LookPopoverIcons> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(DotLook.popoverPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: DotSpace.s,
        children: [
          Row(
            children: [
              TextButton(onPressed: widget.onBack, child: Text(l10n.menuBack)),
              Expanded(
                child: Text(
                  l10n.colourIconMore,
                  textAlign: TextAlign.center,
                  style: lookPopoverLabel(t),
                ),
              ),
              const SizedBox(width: DotTouch.min),
            ],
          ),
          LookSearchField(
            controller: _search,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(
            height: DotLook.popoverLibrary,
            child: LookLibrary(
              lines: libraryLines(
                l10n,
                query: _search.text,
                recent: widget.recent,
              ),
              colour: widget.colour,
              icon: widget.icon,
              onIcon: widget.onIcon,
              controller: _scroll,
              query: _search.text,
              iconSize: DotLook.popoverIcon,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
