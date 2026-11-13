import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
from frames import today_pane
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP2 = open(L + 'E-Phones-2.dc.html', encoding='utf-8').read()
def el(s, marker, tag='div'):
    i = s.index(marker); a = s.rfind('<' + tag, 0, i); return s[a:block(s, a, tag)]
def frame_at(s, st): return s[st:block(s, st, 'div')]
def dlg(st, w, h, top_pat):
    d = el(frame_at(EP2, st), 'role="dialog" aria-label="Day review"')
    d = re.sub(top_pat, 'position: relative; box-sizing: border-box; width: %dpx; height: %dpx; border-radius: 0;' % (w, h), d, count=1)
    d = re.sub(r'box-shadow: 0 -10px 40px rgba\(36,31,43,\.18\);', 'box-shadow: none;', d)
    return re.sub(r'<div aria-hidden="true" style="[^"]*width: (36|32)px; height: (5|4)px;[^"]*"></div>', '', d)
IDR = lambda w, h: dlg(82239, w, h, r'position: absolute; left: 0; right: 0; top: 118px; bottom: 0; z-index: 31; border-radius: 38px 38px 0 0;')
ADR = lambda w, h: dlg(113521, w, h, r'position: absolute; left: 0; right: 0; top: 150px; bottom: 0; z-index: 31; border-radius: 28px 28px 0 0;')
WEEK = EP2[142094:block(EP2, 142094, 'div')].replace('width: 390px; border-radius: 30px;', 'width: 100%; box-sizing: border-box; border-radius: 0;', 1).replace('box-shadow: 0 0 0 1px rgba(36,31,43,.10);', 'box-shadow: none;', 1)
def pane(content, top, w, label, android=False):
    sh = 'box-shadow: -1px 0 0 rgba(36,31,43,.12);'
    return '<aside aria-label="%s" style="position: absolute; right: 0; top: %dpx; bottom: 0; width: %dpx; overflow: hidden; z-index: 30; background: #FBF7F1; %s">%s</aside>' % (label, top, w, sh, content)
F = {}
F['i1'] = device(1180, 820, ipad_sidebar(FULL_ROWS, 'Plan') + workspace_inline(964, 796, ['Tue', 'Wed'], False, 420) + pane(IDR(420, 796), 24, 420, 'Day review, beside the day'), False)
F['i2'] = device(1180, 820, ipad_sidebar(FULL_ROWS, 'Plan') + workspace_inline(964, 796, ['Tue', 'Wed'], False, 420) + pane('<div style="padding: 10px 0 0;">%s</div>' % WEEK, 24, 420, 'Week in review, beside the day'), False)
F['a1'] = device(1280, 800, android_drawer(FULL_ROWS, 'Plan') + workspace_inline(1064, 772, ['Tue', 'Wed', 'Thu'], True, 412) + pane(ADR(412, 772), 28, 412, 'Day review, standard side sheet', True), True)
dbtn = ('<button aria-haspopup="menu" aria-label="Day menu" style="position: absolute; right: 24px; top: 52px; height: 48px; padding: 0 14px 0 18px; border: 0; border-radius: 24px; '
        'background: rgba(239,231,219,0.92); box-shadow: 0 1px 2px rgba(36,31,43,.14), 0 1px 3px 1px rgba(36,31,43,.08); display: flex; align-items: center; gap: 6px; font: 500 15px Roboto, system-ui, sans-serif; color: %s; z-index: 21;">Day%s</button>') % (INK, ic('chev', 18, 2.4))
sheet = ('<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 38;"></div>'
         '<div role="dialog" aria-label="Day review, bottom sheet" style="position: absolute; left: %dpx; width: 640px; bottom: 0; height: 560px; z-index: 40; border-radius: 28px 28px 0 0; overflow: hidden; box-shadow: 0 -10px 40px rgba(36,31,43,.18);">'
         '<div aria-hidden="true" style="position: absolute; top: 10px; left: 50%%; width: 32px; height: 4px; margin-left: -16px; border-radius: 2px; background: #79747E; z-index: 2;"></div><div style="padding-top: 18px; background: #FBF7F1;">%s</div></div>') % (88 + (712 - 640) // 2, ADR(640, 542))
F['a2'] = device(800, 1280, android_rail(['Today', 'Inbox', 'Calendar', 'Search'], 'Today') + dbtn + '<div style="position: absolute; left: 120px; top: 60px;">%s</div>' % today_pane(648) + sheet, True)

def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note=''):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
ri = [fr('i1', 1180, 820, .5, '1 · Day review, a pane beside the day', 'Day ▾ › Review the day (or the Wind Down prompt) opens the one review body (ED-099) as a pane at the right, 420 wide, like the docked editor: “3 of 9 done”, Move the rest to tomorrow? with Move 5 to tomorrow, the sleep line, and Week in review.'),
      fr('i2', 1180, 820, .5, '2 · Week in review, pushed in the same pane', 'Week in review opens inside the pane; Back returns to Day review, as on the phone. “No streaks here — just what happened.”')]
ra = [fr('a1', 1280, 800, .47, '1 · Expanded · Day review in a standard side sheet', 'The approved Android review body beside the grid; the grid narrows to the days that fit.'),
      fr('a2', 800, 1280, .33, '2 · Medium · the phone M3 sheet', 'Medium and compact windows keep the approved phone sheet (here centred, 640 wide, as M3 bottom sheets are on large screens).')]
notes = ['<b>The register’s rule, drawn:</b> iPad landscape and Android expanded show the review as a pane beside the day; narrow iPad Split View, medium and compact windows use the phone sheet (ED-099).',
         '<b>Reused, not redrawn:</b> the approved iPhone and Android Day review bodies and the Week in review page from E-Phones-2, at phone sizes (the touch scale). Same copy; nothing moves until you tap Move 5 to tomorrow (and it shows Undo, R2-7).',
         '<b>The pane behaves like the docked editor</b> (R2-4): the grid narrows to the days that fit, the Plan panel steps aside (ED-184), and opening a task from the pane swaps the pane to the editor.',
         '<b>No-shame copy kept:</b> no streaks, no red; “1 more stays: it repeats or comes from a calendar”.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
def row(title, frs): return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>' % (title, title, ''.join(frs))
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-14 · Day review and Week in review on tablets</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 3, fourth board. Dark on E-R2-14-Dark. Approved by the owner, 13 Nov 2026 (ED-297).</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s%s') % (
            tag('tb', 'Approved · ED-297'), tag('tn', 'Light'), li, row('iPad', ri), row('Android tablet', ra))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-14</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1500px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1500,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-14.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-14</title>', '<title>E · R2-14 · Dark</title>').replace('Dark on E-R2-14-Dark.', 'Light on E-R2-14.').replace('<span class="tn">Light</span>', '<span class="tn">Dark</span>')
open('project/E-R2-14-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
