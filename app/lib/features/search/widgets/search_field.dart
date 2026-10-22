import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The search field (`A-ios-search`): magnifier, text, round × to clear.
/// A leaf: owns only its controller and mirrors [text] when it changes
/// elsewhere (a recent search tapped).
class SearchField extends StatefulWidget {
  const SearchField({
    required this.text,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final String text;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _controller = TextEditingController(text: widget.text);

  @override
  void didUpdateWidget(SearchField old) {
    super.didUpdateWidget(old);
    if (widget.text != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

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
      onSubmitted: widget.onSubmitted,
      decoration: _decoration(context, t),
    );
  }

  InputDecoration _decoration(BuildContext context, DotTheme t) {
    final l10n = context.l10n;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(DotRadii.cardLarge),
      borderSide: BorderSide(color: t.colors.outline),
    );
    return InputDecoration(
      hintText: l10n.searchFieldLabel,
      filled: true,
      fillColor: t.colors.raised,
      prefixIcon: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: DotIcon(
          DotGlyphs.search,
          color: t.colors.accentInk,
          size: DotSize.rowIcon + DotSpace.xxs,
        ),
      ),
      suffixIcon: widget.text.isEmpty
          ? null
          : IconButton(
              tooltip: l10n.searchClear,
              onPressed: () {
                widget.onChanged('');
                _controller.clear();
              },
              icon: DotIcon(
                DotGlyphs.close,
                color: t.colors.muted,
                size: DotSize.rowIcon,
              ),
            ),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: t.colors.accent, width: DotSize.freeLine),
      ),
    );
  }
}
