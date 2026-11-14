# R2-25 · Moving tasks (gap pass): touch drag on phones and tablets, pointer hover and drag on tablets, swipe actions.
# Built behaviour and strings only (app_en.arb): shared/dot/pointer_draggable.dart, thread_drag.dart, thread_drop_target.dart,
# shift_chip.dart, navigation/drag_targets.dart, features/timeline/week/*, shared/dot/inbox_row.dart.
_p = open(os.path.join(HERE, '..', 'r224', 'page224.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')])
import re as _re2
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
import ws
FORK_I = '<path d="M7 3v7a2 2 0 002 2v9M5 3v5M9 3v5M17 21V3c-2 1-3 4-3 7 0 2 1 3 3 3"></path>'
BIN_I = '<path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13"></path>'
PINK = '#D9668F'


def outer(s, i, tag='div'):
    st = s.rfind('<' + tag, 0, i)
    d = 0
    for m in _re2.finditer(r'<%s\b|</%s>' % (tag, tag), s[st:]):
        d += 1 if m.group(0).startswith('<' + tag) else -1
        if d == 0:
            return st, st + m.end()


def dim_row(fr, title):
    i = fr.index('>%s</div>' % title)
    st = fr.rfind('<div role="listitem" style="', 0, i)
    return fr[:st] + fr[st:].replace('style="', 'style="opacity: .38; ', 1)


def add(fr, *layers):
    k = fr.rindex('</div>')
    return fr[:k] + ''.join(layers) + fr[k:]


def finger(x, y): return '<span aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; width: 44px; height: 44px; border-radius: 50%%; background: rgba(36,31,43,.16); box-shadow: 0 0 0 2px rgba(255,255,255,.7); z-index: 36;"></span>' % (x - 22, y - 22)


def cursor(x, y): return ('<svg aria-hidden="true" width="22" height="26" viewBox="0 0 22 26" style="position: absolute; left: %dpx; top: %dpx; z-index: 37;"><path d="M2 2l16 12-7 1 4 8-3 1-4-8-6 5z" fill="#FEFEFE" stroke="#1D1B20" stroke-width="1.6" stroke-linejoin="round"></path></svg>') % (x, y)


def lifted(x, y, rng, f=IOSF, col=PINK, ic=FORK_I, rev=False):
    """The LiftedDot: the task's own dot (upcoming) with a floating shadow, and a dark pill with the time range."""
    return ('<div aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; z-index: 35; display: flex; align-items: center; gap: 8px;%s">'
            '<span style="width: 40px; height: 40px; border-radius: 50%%; background: #FFFDF9; box-shadow: inset 0 0 0 4px %s, 0 10px 24px rgba(36,31,43,.28); color: %s; display: flex; align-items: center; justify-content: center;">%s</span>'
            '<span class="num" style="height: 30px; padding: 0 12px; border-radius: 15px; background: #241F2B; color: #FBF7F1; display: flex; align-items: center; font: 700 14px %s; white-space: nowrap; box-shadow: 0 6px 16px rgba(36,31,43,.22);">%s</span></div>') % (
        x, y, ' flex-direction: row-reverse;' if rev else '', col, col, sv(ic, 20), f, rng)


def preview(y, h, time, title, f=IOSF, left=10, right=10, col=PINK):
    """The LandingPreview: a tinted pill with the dot on the axis, then the time and the title."""
    return ('<div aria-hidden="true" style="position: absolute; left: %dpx; right: %dpx; top: %dpx; height: %dpx; z-index: 30; border-radius: %dpx; background: #E2EFEC; box-shadow: 0 8px 22px rgba(36,31,43,.14); display: flex; align-items: center; gap: 12px; padding-left: 21px;">'
            '<span style="width: 26px; height: 26px; border-radius: 50%%; background: #FFFDF9; box-shadow: inset 0 0 0 3px %s; flex: none;"></span>'
            '<span class="num" style="font: 700 14px %s; color: #0B4642;">%s</span><span style="font: 700 16px Manrope; color: #241F2B;">%s</span></div>') % (
        left, right, y, h, h // 2, col, f, time, title)


def chips(on=False, cal=False, f=IOSF, top=194):
    c1 = ('<span style="height: 36px; padding: 0 14px; border-radius: 18px; display: flex; align-items: center; gap: 6px; font: 700 14px %s; box-shadow: 0 8px 20px rgba(36,31,43,.16); %s">%sShift later tasks</span>') % (
        f, 'background: #CFE8E4; color: #062F2C;' if on else 'background: #FFFDF9; color: #241F2B; box-shadow: inset 0 0 0 1.5px #DDD7E0, 0 8px 20px rgba(36,31,43,.16);', sv(CHECK, 15, 2.6) if on else '')
    c2 = ('<span style="height: 36px; padding: 0 14px; border-radius: 18px; display: flex; align-items: center; font: 700 14px %s; background: #FFFDF9; color: #241F2B; box-shadow: inset 0 0 0 1.5px #DDD7E0, 0 8px 20px rgba(36,31,43,.16);">Calendar events too</span>') % f if cal else ''
    return '<div role="group" style="position: absolute; left: 0; right: 0; top: %dpx; z-index: 34; display: flex; justify-content: center; gap: 8px;">%s%s</div>' % (top, c1, c2)


def trash_bin(hover=False, right=26, bottom=168):
    return ('<span role="img" aria-label="Move to Trash" style="position: absolute; right: %dpx; bottom: %dpx; z-index: 33; width: 52px; height: 52px; border-radius: 50%%; display: flex; align-items: center; justify-content: center; %s">%s</span>') % (
        right, bottom, 'background: #241F2B; color: #FBF7F1; transform: scale(1.15);' if hover else 'background: #FFFDF9; color: #241F2B; box-shadow: 0 0 0 1px rgba(36,31,43,.12), 0 8px 20px rgba(36,31,43,.14);', sv(BIN_I, 22))


ALLDAY = ('<div aria-hidden="true" style="position: absolute; left: 10px; right: 10px; top: 240px; height: 44px; z-index: 30; border-radius: 22px; background: #E2EFEC; box-shadow: inset 0 0 0 1.5px #11615C; display: flex; align-items: center; padding-left: 64px; font: 700 15px Manrope; color: #0B4642;">All day</div>')
BASE = dim_row(EP_TODAY, 'Lunch')
P1 = add(BASE, chips(), trash_bin(), preview(638, 40, '11:15 AM', 'Lunch'), lifted(150, 600, '11:15 AM – 12:00 PM'), finger(170, 620))
P2 = add(BASE, chips(), trash_bin(), preview(568, 46, '10:45 AM', 'Lunch'), lifted(150, 528, '10:45 – 11:30 AM'), finger(170, 548))
P3 = add(BASE, chips(True, True), trash_bin(), preview(638, 40, '11:15 AM', 'Lunch'), lifted(150, 600, '11:15 AM – 12:00 PM'), finger(170, 620))
P4 = add(BASE, chips(), trash_bin(), ALLDAY, lifted(170, 214, 'All day'), finger(190, 234))
P5 = add(BASE, chips(), trash_bin(True), lifted(156, 602, '1:45 – 2:30 PM', rev=True), finger(338, 650))
A_BASE = dim_row(EP_ATODAY, 'Lunch')
A1 = add(A_BASE, chips(f=ANF, top=212), trash_bin(right=28, bottom=110), preview(664, 40, '11:15 AM', 'Lunch', ANF), lifted(150, 626, '11:15 AM – 12:00 PM', ANF), finger(170, 646))
DROP_TOASTS = [('Lunch moved to 11:15 AM', 'Undo'), ('Lunch moved to 11:15 AM · 3 later tasks moved too', 'Undo'), ('Lunch moved to 11:15 AM · stopped at Gym (pinned)', 'Undo'),
               ('Lunch moved to All day', 'Undo'), ('Lunch moved to inbox', 'Undo'), ('Lunch moved to Trash', 'Undo')]

# ---------------------------------------------------------------- tablets: the approved Workspace grid (R2-2), HOUR 96 from 8 AM at y 146
def iwork():
    return ws.device(1180, 820, ws.ipad_sidebar(ws.FULL_ROWS, 'Plan') + ws.workspace(964, 796, ['Tue', 'Wed', 'Thu'], False), False)


def awork():
    return ws.device(1280, 800, ws.android_drawer(ws.FULL_ROWS, 'Plan') + ws.workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True), True)


def card_html(fr, label):
    i = fr.index('aria-label="%s"' % label)
    st = fr.rfind('<button', 0, i)
    e = fr.index('</button>', i) + 9
    return st, e


def dim_card(fr, label):
    st, e = card_html(fr, label)
    return fr[:st] + fr[st:e].replace('style="', 'style="opacity: .38; ', 1) + fr[e:]


def lifted_card(fr, label, x, y):
    st, e = card_html(fr, label)
    c = _re2.sub(r'left: -?\d+px; top: -?\d+px;', 'left: 0; top: 0;', fr[st:e], count=1)
    return ('<div aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; width: 210px; height: 68px; z-index: 40; filter: drop-shadow(0 14px 22px rgba(36,31,43,.28));">%s</div>') % (x, y, c)


def drop_box(x, y, w, h, label, f=IOSF):
    return ('<div aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; width: %dpx; height: %dpx; z-index: 38; border-radius: 16px; background: rgba(17,97,92,.10); box-shadow: inset 0 0 0 2px #11615C;"></div>'
            '<span class="num" style="position: absolute; left: %dpx; top: %dpx; z-index: 39; height: 28px; padding: 0 12px; border-radius: 14px; background: #11615C; color: #fff; display: flex; align-items: center; font: 700 13px %s; white-space: nowrap;">%s</span>') % (
        x, y, w, h, x, y - 34, f, label)


def tadd(fr, *layers):
    k = fr.rindex('</div>')
    return fr[:k] + ''.join(layers) + fr[k:]


_IP = iwork()
T1 = tadd(dim_card(_IP, 'Lunch, 12:30 to 1:15'), drop_box(740, 434, 210, 72, 'Wed · 11:00 – 11:45 AM'), lifted_card(_IP, 'Lunch, 12:30 to 1:15', 752, 452), finger(860, 488))
# Pointer: ED-116 flat hover tint on the card under the pointer; a mouse lifts at once, the drop box is the same.
_hst, _he = card_html(_IP, 'Deep work, 9:00 to 10:30')
T2 = tadd(_IP[:_hst] + _IP[_hst:_he].replace('style="', 'style="background: rgba(91,95,214,.18); ', 1) + _IP[_he:], cursor(850, 300))
T2b = tadd(dim_card(_IP, 'Lunch, 12:30 to 1:15'), drop_box(740, 434, 210, 72, 'Wed · 11:00 – 11:45 AM'), lifted_card(_IP, 'Lunch, 12:30 to 1:15', 746, 440), cursor(850, 470))
_AN = awork()
INBOX_CHIP = ('<div aria-hidden="true" style="position: absolute; left: 1110px; top: 452px; z-index: 40; height: 44px; padding: 0 18px; border-radius: 22px; background: #FFFDF9; box-shadow: inset 0 0 0 2px #469763, 0 14px 24px rgba(36,31,43,.26); display: flex; align-items: center; font: 700 15px Roboto, system-ui; color: #241F2B; white-space: nowrap;">Book the car service</div>')
T3 = tadd(_AN, drop_box(1094, 438, 180, 48, 'Thu · 11:00 – 11:30 AM', ANF), INBOX_CHIP, finger(1190, 474))

# ---------------------------------------------------------------- swipe on phone Inbox rows (R2-13 frames)
_R13 = open('/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/a21b100f-12b5-489d-9702-7c7846acea81/scratchpad/audit/project/E-R2-13.dc.html', encoding='utf-8').read()
def _frame13(st):
    d = 0
    for m in _re2.finditer(r'<div\b|</div>', _R13[st:]):
        d += 1 if m.group(0) == '<div' else -1
        if d == 0:
            return _R13[st:st + m.end()]
I_INBOX, A_INBOX = _frame13(5139), _frame13(14688)


def swipe(fr, direction, f=IOSF):
    i = fr.index('>Buy a birthday gift</div>')
    st = fr.rfind('<div role="listitem"', 0, i)
    s0, e0 = outer(fr, st + 5)
    row = fr[s0:e0]
    if direction == 'trash':   # start → end: Move to Trash, coral tint, label at the start
        bg = '<div aria-hidden="true" style="position: absolute; inset: 0; border-radius: 18px; background: rgba(226,114,91,.24); display: flex; align-items: center; gap: 8px; padding-left: 18px; color: #8F341F; font: 700 15px %s;">%sMove to Trash</div>' % (f, sv(BIN_I, 20))
        tr = 'translateX(150px)'
    else:                      # end → start: Schedule, accent tint, label at the end
        bg = '<div aria-hidden="true" style="position: absolute; inset: 0; border-radius: 18px; background: #E2EFEC; display: flex; align-items: center; justify-content: flex-end; gap: 8px; padding-right: 18px; color: #0B4642; font: 700 15px %s;">Schedule%s</div>' % (f, sv(CAL_I, 20))
        tr = 'translateX(-130px)'
    moved = row.replace('style="', 'style="position: relative; transform: %s; box-shadow: 0 8px 20px rgba(36,31,43,.14); ' % tr, 1)
    return fr[:s0] + '<div style="position: relative; overflow: hidden; border-radius: 18px;">' + bg + moved + '</div>' + fr[e0:]


def hint(fr, f=ANF):
    i = fr.index('>Buy a birthday gift</div>')
    st = fr.rfind('<div role="listitem"', 0, i)
    s0, e0 = outer(fr, st + 5)
    return fr[:e0] + '<div aria-hidden="true" style="text-align: center; font: 600 13px %s; color: #6A6273;">← Schedule · Move to Trash →</div>' % f + fr[e0:]


S1 = swipe(I_INBOX, 'trash')
S2 = swipe(I_INBOX, 'schedule')
S3 = hint(swipe(A_INBOX, 'schedule', ANF))
SW_TOASTS = [('Buy a birthday gift moved to Trash', 'Undo'), ('Buy a birthday gift scheduled for Today, 11:00–11:30 AM', 'Undo')]

# ---------------------------------------------------------------- page
def fcol(w, lab, fr, *n): return col(w, label(lab), fr, notes(*n))
def scaled(fr, w, h, sc): return '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>' % (w * sc + 14, h * sc + 14, w, h, sc, fr)
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start;">%s</div>' % ''.join(c)
stack = lambda *c: '<div style="display: flex; flex-direction: column; gap: 18px;">%s</div>' % ''.join(c)
TS = lambda L, w=420: '<div style="display: flex; flex-direction: column; gap: 10px;">%s</div>' % ''.join(toast(t, a, w) for t, a in L)
s1 = (row(fcol(390, 'iPhone · hold Lunch, then move', P1, B('Built') + ' Hold the row 250 ms to lift it (a mouse lifts at once). The row stays, dimmed; the dot follows the finger with the time range', B('Built') + ' The landing preview sits on the thread: dot on the axis, the time, the title. Snaps to Settings › Planning › Snap to (5 min)', B('Built') + ' “Shift later tasks” floats at the top; the Trash bin appears above the +'),
          fcol(390, 'iPhone · over another task', P2, B('Built') + ' Over a task the drop lands at the finger and overlaps (ADR-0015); the knot appears after the drop, not while dragging'),
          fcol(390, 'iPhone · Shift later tasks on', P3, B('Built') + ' Tap the chip with a second finger (or click); with calendar events it could carry, “Calendar events too” joins it', B('Built') + ' Settings › Planning › Shift later tasks: Ask each time · Always · Never'),
          fcol(390, 'iPhone · on the Wake Up cap: All day', P4, B('Built') + ' The Wake Up cap is the All-day drop zone; the Wind Down cap is not a target'))
      + row(fcol(390, 'iPhone · over the Trash bin', P5, B('Built') + ' The bin fills with ink on hover, never red; the Inbox tab grows while a task is over it and unschedules it'),
            fcol(412, 'Android · hold Lunch, then move', A1, B('Built') + ' The same lift, preview, chip and bin; the same haptics'),
            col(420, label('After the drop (the approved toast, R2-7)'), TS(DROP_TOASTS), notes(B('Built') + ' One write, with Undo for 30 s')),
            col(400, label('Rules as built'), notes(B('Built') + ' Haptics: a tick on lift, a tick each time the time changes, a firmer one on drop (Settings › Sounds › Haptics in app)',
                                                 B('Built') + ' Near the top or bottom edge the day scrolls by itself',
                                                 B('Built') + ' Let go anywhere that is not a target to cancel; letting go in place selects the task instead (R-05)',
                                                 B('Built') + ' Done and pinned tasks don’t lift', B('Built') + ' Screen readers: Select, then Move in the selection bar, or Move on the task sheet'))))
s2 = (row(col(1180 * .5 + 14, label('iPad · touch: hold a card, then drop it on Wednesday'), scaled(T1, 1180, 820, .5), notes(B('Built') + ' Hold 250 ms; the card itself follows the finger; the original dims; the column shows the drop box and “Wed · 11:00 – 11:45 AM”', B('Built') + ' The Week grid snaps to 15 min; past days accept drops')),
          col(1180 * .5 + 14, label('iPad · pointer: hover, then drag'), scaled(T2, 1180, 820, .5), notes(B('Approved') + ' Hover is a flat tint, no lift; the lift is only while dragging (ED-116)', B('Built') + ' A mouse or trackpad click-drag lifts at once, with the same drop box')))
      + row(col(1180 * .5 + 14, label('iPad · pointer drag'), scaled(T2b, 1180, 820, .5), notes(B('Built') + ' The pointer replaces the finger; nothing else changes')),
            col(1280 * .46 + 14, label('Android tablet · an Inbox task onto Thursday'), scaled(T3, 1280, 800, .46), notes(B('Built') + ' Inbox rows drag as a chip with the title and the task colour; drop on a column or a dotted gap', B('Built') + ' Toast: “… scheduled for …”, with Undo'))))
s3 = (row(fcol(390, 'iPhone · Inbox: swipe right', S1, B('Built') + ' Start → end: Move to Trash. A full swipe acts; the row comes back and leaves when the write lands, with Undo', D('Design-only') + ' The coral tint and the slid row'),
          fcol(390, 'iPhone · Inbox: swipe left', S2, B('Built') + ' End → start: Schedule opens the schedule sheet', B('Built') + ' Directions follow reading direction'),
          fcol(412, 'Android · Inbox: swipe left, with the first-row hint', S3, B('Built') + ' Identical on Android; the hint “← Schedule · Move to Trash →” sits under the first row'),
          col(420, label('Toasts'), TS(SW_TOASTS), notes(B('Built') + ' Swipes exist only on phone Inbox rows; day rows, search results and wide Inbox lists have none', B('Built') + ' Long-press or right-click: Schedule, Move to Trash, Select'))))
RULES = [('Moving is direct', 'Drag writes one move, with Undo. Shift later tasks is the one-gesture “shift everything after this” (R-04, R-05).'),
         ('Hold to lift, hold to select', 'The same 250 ms hold lifts a row; letting go in place selects it instead, so multi-select still starts from a hold (R-05).'),
         ('No shame', 'The Trash bin fills with ink, never red; the coral tint is the built swipe colour, not a warning.'),
         ('Touch and pointer', 'Touch, pen and trackpad hold first; a mouse lifts at once. Hover is a flat tint, no lift (ED-116).'),
         ('Same everywhere (R-13)', 'Phones, tablets, Mac and web share the drag; Mac and web use the pointer frames.'),
         ('Text from the app', 'Every string is built (app_en.arb). Times and tasks are examples. No new copy.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 GAP PASS · R2-25</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Moving tasks</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">Touch drag on phones and tablets, pointer hover and drag on tablets, and swipe actions, as built. Drawn on the approved Today, Workspace and Inbox frames. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · gap pass · not recorded yet'), tag('tn', 'iPhone, Android, iPad, Android tablet'), tag('tn', '@@THEME@@'))
page_body = body + section('1 · Touch drag on phones', s1) + section('2 · Tablets: touch and pointer', s2) + section('3 · Swipe actions', s3) + section('Rules', rules)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-25 · Moving tasks</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-25-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-25.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-25.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('color: #8F341F;', 'color: #F4A38E;').replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('class="blk-d', 'class="blk').replace('<title>E · R2-25 · Moving tasks</title>', '<title>E · R2-25 · Moving tasks · Dark</title>')
open('project/E-R2-25-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok')
