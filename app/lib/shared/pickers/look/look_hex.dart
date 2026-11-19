import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The hex in All colours' title row (ED-156; owner, 4c-2: tap to type).
/// Shows [colour]'s `#RRGGBB`; tapped it becomes a field, and a full
/// six-digit value applies as typed.
class HexChip extends StatefulWidget {
  const HexChip({required this.colour, required this.onColour, super.key});

  final Color colour;
  final ValueChanged<Color> onColour;

  @override
  State<HexChip> createState() => _HexChipState();
}

/// A leaf: the field's text and focus.
class _HexChipState extends State<HexChip> {
  late final _text = TextEditingController(text: hexOf(widget.colour));
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      // Leaving the field shows the colour in use again.
      if (!_focus.hasFocus) _text.text = hexOf(widget.colour);
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(HexChip old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && old.colour != widget.colour) {
      _text.text = hexOf(widget.colour);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _typed(String v) {
    final c = parseHex(v);
    if (c != null && c != widget.colour) widget.onColour(c);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      label: context.l10n.lookHexLabel,
      textField: true,
      child: IntrinsicWidth(
        child: TextField(
          controller: _text,
          focusNode: _focus,
          onChanged: _typed,
          onSubmitted: (_) => _focus.unfocus(),
          style: t.styles.hexCode,
          textAlign: TextAlign.center,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.visiblePassword,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(hexCharacters),
            LengthLimitingTextInputFormatter(hexLength),
          ],
          decoration: InputDecoration(
            labelText: null,
            semanticCounterText: '',
            hintText: context.l10n.lookHexLabel,
            isDense: true,
            filled: true,
            fillColor: t.colors.raised,
            constraints: const BoxConstraints(minHeight: DotTouch.min),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DotSpace.s,
              vertical: DotSpace.s,
            ),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(DotSpace.m)),
              borderSide: BorderSide(color: t.colors.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(DotSpace.m)),
              borderSide: BorderSide(color: t.colors.hairline),
            ),
          ),
        ),
      ),
    );
  }
}
