import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP2 = open(L + 'E-Phones-2.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
def el(s, marker, tag='div'):
    i = s.index(marker); a = s.rfind('<' + tag, 0, i); return s[a:block(s, a, tag)]
def as_box(h, w, hgt, pat):
    h = re.sub(pat, 'position: relative; box-sizing: border-box; width: %dpx; height: %dpx; border-radius: 0; background: #FBF7F1; padding: 0 16px; box-shadow: none; overflow: hidden;' % (w, hgt), h, count=1)
    return re.sub(r'<div aria-hidden="true" style="[^"]*width: (36|32)px; height: (5|4)px;[^"]*"></div>', '', h)
when_ios = as_box(el(frame_at(EP2, 147637), 'role="dialog" aria-label="Move Pick up parcel"'), 400, 640,
                  r'position: absolute; left: 0; right: 0; top: 150px; bottom: 0; z-index: 31; border-radius: 38px 38px 0 0; background: #FBF7F1; padding: 0 16px; box-shadow: 0 -10px 40px rgba\(36,31,43,\.18\); overflow: hidden;')
when_and = as_box(el(frame_at(EP2, 182773), 'role="dialog" aria-label="Schedule Go for a run"'), 412, 772,
                  r'position: absolute; left: 0; right: 0; top: 170px; bottom: 0; z-index: 31; border-radius: 28px 28px 0 0; background: #FBF7F1; padding: 0 16px; box-shadow: 0 -10px 40px rgba\(36,31,43,\.18\); overflow: hidden;')
def menu_at(a, right, top):
    m = EP2[a:block(EP2, a, 'div')]
    m = re.sub(r'position: absolute; top: 0; left: 0; (width: \d+px;) transform: scale\(0\.8\); transform-origin: top left;', r'position: absolute; top: %dpx; right: %dpx; \1 z-index: 40;' % (top, right), m, count=1)
    return m
day_ios = menu_at(220549, 70, 84); day_and = menu_at(235494, 70, 88)

TUE0 = list(ws.WEEK['Tue'])
def with_tue(rows, fn):
    ws.WEEK['Tue'] = rows
    try: return fn()
    finally: ws.WEEK['Tue'] = TUE0
DONE = [r if r[0] != 'Deep work: roadmap' else (r[0], r[1], r[2], r[3], 'done') for r in TUE0]
# the selected outline follows Deep work: drop it once done
def no_sel(h): return h.replace(', now, 18 minutes left, selected', '').replace(' aria-pressed="true"', '').replace(' box-shadow: 0 0 0 2.5px #11615C; z-index: 2;', '')

IP = lambda body: device(1180, 820, ipad_sidebar(FULL_ROWS, 'Plan') + body, False)
AN = lambda body: device(1280, 800, android_drawer(FULL_ROWS, 'Plan') + body, True)
F = {}
F['ip1'] = IP(with_tue(DONE, lambda: workspace(964, 796, ['Tue', 'Wed', 'Thu'], False)))
def later():
    ws.T0 = 9.0
    try: return workspace(964, 796, ['Tue', 'Wed', 'Thu'], False)
    finally: ws.T0 = 8.0
F['ip2'] = IP(with_tue(DONE, later) + ('<div role="dialog" aria-label="Move Pick up parcel" style="position: absolute; left: 760px; top: 160px; width: 400px; height: 640px; border-radius: 26px; overflow: hidden; z-index: 40; '
                                        'box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 18px 48px rgba(36,31,43,.22);">%s</div>'
                                        '<span aria-hidden="true" style="position: absolute; left: 749px; top: 686px; width: 22px; height: 22px; background: #FBF7F1; transform: rotate(45deg); border-radius: 4px; z-index: 39;"></span>') % when_ios)
F['ip4'] = IP(with_tue(DONE, lambda: workspace(964, 796, ['Tue', 'Wed', 'Thu'], False)) + day_ios)
F['an1'] = AN(with_tue(DONE, lambda: workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True)))
F['an2'] = AN(with_tue(DONE, lambda: workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True))
              + '<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 38;"></div>'
              + '<aside aria-label="Schedule, modal side sheet" style="position: absolute; right: 0; top: 28px; bottom: 0; width: 412px; border-radius: 28px 0 0 28px; overflow: hidden; z-index: 40; box-shadow: -8px 0 28px rgba(36,31,43,.14);">%s</aside>' % when_and)
F['an4'] = AN(with_tue(DONE, lambda: workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True)) + day_and)
for k in F: F[k] = no_sel(F[k]) if k != 'ip2' else no_sel(F[k])

# reopen: the block before and after, at 100 %
def blk(st):
    c = card('Deep work: roadmap', 9, 10.5, '#5B5FD6', st, 0, 230)
    return '<div style="position: relative; width: 230px; height: 150px;">%s</div>' % re.sub(r'top: [\d.]+px;', 'top: 0;', c, count=1)
reopen = ('<div style="display: flex; align-items: center; gap: 20px; padding: 24px; border-radius: 24px; background: #EFE7DB; width: fit-content;">%s'
          '<div style="font: 700 15px Manrope; color: #4E4757; text-align: center; width: 150px;">Tap the dot<br><span style="font-size: 26px;">→</span><br>Reopen</div>%s</div>') % (no_sel(blk('done')), no_sel(blk('now')))

SC = 0.45
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, label, note):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * SC + 14, label, w * SC + 14, h * SC + 14, w, h, SC, F[key], note)
row_ip = [fr('ip1', 1180, 820, '1 · Complete', 'The done check on the block (or Done in the docked editor) marks Deep work done: the dot fills in its colour, the title greys, the thread turns solid. Call with Sam becomes the current task. Autosave, as built; the Undo toast is drawn in stage 2.'),
          fr('ip2', 1180, 820, '2 · Change day: Move → the When picker', 'Move (editor tile, or hold a block) opens the one When picker (ED-099) as a popover from the block: free time first, then a day and the thread; it keeps the task’s length. The grid is scrolled to the afternoon.'),
          '<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">3 · Reopen (at 100 %)</figcaption>' + reopen +
          '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757; width: 460px;">Tapping a done task’s dot reopens it, as on the phones (“Morning run, done. Reopen”): the progress ring and “Now, 18 min left” return while the task is under way. Same in the docked editor’s Done tile.</div></figure>',
          fr('ip4', 1180, 820, '4 · The Day menu, Full (by width, ED-254)', 'Day ▾ opens Full’s grouped menu (Time · Plan · Day · Layout, ED-093) as the native pull-down. Minimal tablets get E-Minimal’s menu (ED-254, drawn on E-T2).')]
row_an = [fr('an1', 1280, 800, '1 · Complete', 'Same done state on Android.'),
          fr('an2', 1280, 800, '2 · Change day: Schedule / Move in a modal side sheet', 'The When picker as an M3 modal side sheet (ED-099: side sheet on Android expanded). Sample text as approved on E-Phones-2 (“Schedule Go for a run”, from the Inbox); Move uses the same sheet.'),
          fr('an4', 1280, 800, '4 · The Day menu (M3)', 'The same groups as an M3 menu anchored to the toolbar Day button.')]
notes = ['<b>One connected journey (ED-166):</b> Today (R2-2) → Add (R2-3) → Edit (R2-4) → Complete → Change day → Reopen, on the same sample day, inside the approved navigation (R2-1).',
         '<b>Reused, not redrawn:</b> the When picker (E-Phones-2, ED-099), the Full Day menus (iPhone glass, Android M3), and the done and reopen states of the phone thread. Phone sizes are the touch scale (ED-256).',
         '<b>Medium and compact:</b> the same picker floats from the row on medium iPads and opens as a modal side sheet from the rail on Android; compact windows keep the phone sheets (ED-099).',
         '<b>Stage 2 next:</b> multi-select and the selection bar, Undo, sync states, Focus, keyboard overlays.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-5 · Complete, change day, reopen and the Day menu on expanded tablets</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">The last board of stage 1 (core journey). On the approved touch Workspace (R2-2) with the approved navigation (R2-1). Frames at 45 %%. Dark on E-R2-5-Dark. Approved by the owner, 13 Nov 2026 (ED-276); stage 1 complete.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>'
        '<section aria-label="iPad" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">iPad</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>'
        '<section aria-label="Android tablet" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">Android tablet</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>') % (
            tag('tb', 'Approved · ED-276'), tag('tn', 'Light'), li, ''.join(row_ip), ''.join(row_an))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-5</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 2560px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2560,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-5.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('background: #F7EFF4;', 'background: #37313A;').replace('<title>E · R2-5</title>', '<title>E · R2-5 · Dark</title>').replace('Dark on E-R2-5-Dark.', 'Light on E-R2-5.').replace('>Light</span>', '>Dark</span>')
open('project/E-R2-5-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
