# Approved frames lifted from the live E-Phones board (version 1794612394-b691), so R2-23 draws on the
# exact approved Today and task sheet: iPhone Today (G3-1, ED-104), task sheet medium (G2-5 D, ED-086),
# full editor with steps (ED-086), Android Today and Android task sheet.
import re as _re
_EP = open('/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/a21b100f-12b5-489d-9702-7c7846acea81/scratchpad/back321/project/E-Phones.dc.html', encoding='utf-8').read()


def _frame(st):
    d = 0
    for m in _re.finditer(r'<div\b|</div>', _EP[st:]):
        d += 1 if m.group(0) == '<div' else -1
        if d == 0:
            return _EP[st:st + m.end()]
    raise ValueError(st)


EP_TODAY, EP_SHEET, EP_EDITOR, EP_ATODAY, EP_ASHEET, EP_EMPTY = (_frame(x) for x in (5323, 60704, 413569, 87361, 113945, 434527))
