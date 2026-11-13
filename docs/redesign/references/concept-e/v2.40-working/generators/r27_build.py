import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP1 = open(L + 'E-Phones.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
IPH, AND = frame_at(EP1, 5323), frame_at(EP1, 87361)
XI = '<svg class="i" width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"></path></svg>'
def toast(msg, pos, radius, undo=True, close=False, undo_label='Undo', width=None, font='Manrope, system-ui'):
    """The approved bottom confirmation (E-G4-7-States C3, ED-194): ink surface, cream text, light-teal Undo.
    Dark: cream surface with dark-teal Undo (as approved). @@U@@ marks the Undo colour for the dark pass."""
    w = ('width: %dpx;' % width) if width else ''
    u = ('<button aria-label="%s" style="margin-left: auto; height: 44px; padding: 0 12px; border: 0; background: none; color: @@U@@; font: 700 15px %s;">Undo</button>' % (undo_label, font)) if undo else ''
    c = ('<button aria-label="Close" style="%s width: 44px; height: 44px; border: 0; background: none; color: #FBF7F1; display: flex; align-items: center; justify-content: center;">%s</button>' % ('' if undo else 'margin-left: auto;', XI)) if close else ''
    return ('<div role="status" aria-live="polite" style="position: absolute; %s %s z-index: 45; min-height: 52px; border-radius: %dpx; background: #2E2836; color: #FBF7F1; display: flex; align-items: center; gap: 8px; '
            'padding: 4px 4px 4px 16px; box-sizing: border-box; font: 600 15px/20px %s; box-shadow: 0 8px 24px rgba(36,31,43,.20);"><span style="min-width: 0;">%s</span>%s%s</div>') % (pos, w, radius, font, msg, u, c)
def phone_with(fr, t): return fr[:-6] + t + '</div>'
IOSF = "-apple-system, 'SF Pro Text', system-ui, sans-serif"; ANF = 'Roboto, system-ui, sans-serif'
F = {}
F['ip'] = phone_with(IPH, toast('Marked done', 'left: 16px; right: 16px; bottom: 100px;', 16, undo_label='Undo: Morning run, marked done', font=IOSF))
F['an'] = phone_with(AND, toast('Read moved to Wed 4 Nov', 'left: 16px; right: 16px; bottom: 112px;', 8, undo_label='Undo: Read moved to Wed 4 Nov', font=ANF))
TUE0, WED0 = list(ws.WEEK['Tue']), list(ws.WEEK['Wed'])
DONE = [r if r[0] != 'Deep work: roadmap' else (r[0], r[1], r[2], r[3], 'done') for r in TUE0]
def nosel(h): return h.replace(', now, 18 minutes left, selected', '').replace(' aria-pressed="true"', '').replace(' box-shadow: 0 0 0 2.5px #11615C; z-index: 2;', '')
ws.WEEK['Tue'] = DONE
ipw = nosel(workspace(964, 796, ['Tue', 'Wed', 'Thu'], False))
ws.WEEK['Tue'] = [r for r in TUE0 if r[0] not in ('Lunch', 'Dentist')]; ws.WEEK['Wed'] = [r for r in WED0 if r[0] != 'Lunch']
anw = nosel(workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True))
ws.WEEK['Tue'], ws.WEEK['Wed'] = TUE0, WED0
gx = 216 + 240
F['tip'] = device(1180, 820, ipad_sidebar(FULL_ROWS, 'Plan') + ipw + toast('Marked done', 'left: %dpx; bottom: 28px;' % (gx + (1180 - gx - 400) // 2), 16, undo_label='Undo: Deep work: roadmap, marked done', width=400, font='-apple-system, system-ui, sans-serif'), False)
F['tan'] = device(1280, 800, android_drawer(FULL_ROWS, 'Plan') + anw + toast('3 tasks moved to Trash', 'left: %dpx; bottom: 28px;' % (gx + 24), 8, undo_label='Undo: 3 tasks moved to Trash', width=440, font=ANF), True)

# states strip at 100 %
def strip_box(t, w=420, h=84, note=''):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><div style="position: relative; width: %dpx; height: %dpx; border-radius: 18px; background: #EFE7DB;">%s</div>'
            '<figcaption style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</figcaption></figure>') % (w, w, h, t, note)
P = 'left: 16px; right: 16px; top: 16px;'
states = [
 strip_box(toast('Marked done', P, 16), note='<b>Standard.</b> One line, Undo at the end. Only the latest change is offered; a new one replaces it (built).'),
 strip_box(toast('Marked done', P, 16, close=True), note='<b>Screen reader on.</b> Stays until dismissed and gains Close (✕); the message is announced (ED-194 kit rule).'),
 strip_box(toast('Deep work: roadmap moved to Wed 4 Nov · 2 later tasks moved too', P, 16), h=104, note='<b>Long text</b> wraps to two lines; Undo keeps its place. Built string <code>snackMovedShifted</code>.'),
 strip_box(toast("That can't be undone any more. Deleted tasks stay in Trash for 30 days.", P, 16, undo=False, close=True), h=104, note='<b>Too late.</b> Undo tapped after its window: the built failure text, with Close only.'),
 strip_box(toast('<span style="font-size: 30px; line-height: 38px;">Marked done</span>', P, 16), h=96, note='<b>200 % text.</b> The surface grows; the Undo target stays 44 high.'),
]
SC = 0.5
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
devs = [fr('ip', 390, 844, .62, 'iPhone · after completing Morning run', 'Floats above the tab bar (rules §9, iPhone row), radius 16, as approved for the conflict Undo.'),
        fr('an', 412, 892, .6, 'Android phone · after a move', 'The M3 snackbar shape (radius 8) above the floating toolbar, as on E-G4-7-States.'),
        fr('tip', 1180, 820, .5, 'iPad · after Done in the docked editor (R2-5)', 'Centred under the grid, 400 wide, clear of the Plan panel.'),
        fr('tan', 1280, 800, .5, 'Android tablet · after Delete in the selection card (R2-6)', 'M3 snackbar at the start of the grid on large screens, 440 wide.')]
notes = ['<b>One confirmation everywhere:</b> the bottom confirmation approved for the conflict Undo (E-G4-7-States C3, ED-194) becomes the Undo toast for every move, delete, done and shift. No second design (CR-079).',
         '<b>Built behaviour kept:</b> 30-second window (<code>UndoService.window</code>, R-11); a new change replaces the toast; ⌘Z / Ctrl+Z undoes outside a text field and ⇧⌘Z / Ctrl+Shift+Z redoes (built, <code>app_menu.dart</code>); Mac also has Edit › Undo / Redo.',
         '<b>Kit rules applied (ED-194):</b> the window pauses while the toast is focused or hovered; Escape, swipe or the screen reader’s dismiss gesture closes it; with VoiceOver or TalkBack on it stays until dismissed; no visible countdown; Reduced Motion honoured. These are design rules: check them in the build.',
         '<b>Copy</b> is built strings only: “Marked done”, “{title} moved to {day}”, “3 tasks moved to Trash”, “Undo”, and the too-late text. No-shame: nothing says late or missed.',
         '<b>Mac and web</b> use the tablet placement (centred under the content); the conflict Undo keeps its own place in the Sync popover (C5).']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-7 · Undo: the toast and ⌘Z / Ctrl+Z (all platforms)</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 2, second board. Undo is built but drawn on no E board apart from the sync-conflict case (CR-079), so this covers phones and tablets together. Dark on E-R2-7-Dark. Approved by the owner, 13 Nov 2026 (ED-281).</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>'
        '<section aria-label="On each platform" style="display: flex; gap: 24px; align-items: flex-start;">%s</section>'
        '<section aria-label="States" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">States (100 %%)</div><div style="display: flex; gap: 24px; align-items: flex-start;">%s</div></section>') % (
            tag('tb', 'Approved · ED-281'), tag('tn', 'Light'), li, ''.join(devs), ''.join(states))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-7</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 2400px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2400,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-7.dc.html', 'w', encoding='utf-8').write(page.replace('@@U@@', '#A3E2D9'))
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('@@U@@', '#0B4642').replace('<title>E · R2-7</title>', '<title>E · R2-7 · Dark</title>').replace('Dark on E-R2-7-Dark.', 'Light on E-R2-7.').replace('>Light</span>', '>Dark</span>')
# toast Close icon: cream on ink in light -> ink on cream in dark (darkify maps #FBF7F1 -> #171416 already)
open('project/E-R2-7-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
