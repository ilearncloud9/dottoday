import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
H = int(sys.argv[1])
from ws import *
F = {}
F['ipad'] = device(1180, 820, ipad_sidebar(FULL_ROWS, 'Plan') + workspace(964, 796, ['Tue', 'Wed', 'Thu'], False), False)
F['and'] = device(1280, 800, android_drawer(FULL_ROWS, 'Plan') + workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True), True)
SC = 0.75
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, label):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div></figure>' % (label, w * SC + 14, h * SC + 14, w, h, SC, F[key]))
notes = [
 '<b>What changes from Mac:</b> only content size and spacing (ED-256): task titles 17, times 13, the current task’s ring 45 with “Now, 18 min left”, other dots 36 with their icons, Plan-panel rows 60 tall, every control 44 pt / 48 dp. Same parts in the same places: sidebar, Plan panel, toolbar, grid with a thread per day, now line, overlap of Deep work and Call with Sam.',
 '<b>Week shows the days that fit:</b> as on Mac (the 1160 window shows Monday to Thursday), the week scrolls sideways and shows as many days as keep a column of at least 180. iPad 1180 shows 3 (Tue–Thu, scrolled to today); Android 1280 shows 4 (Mon–Thu). The Plan panel stays while 3 or more days fit (ED-184).',
 '<b>The inspector floats here:</b> at touch sizes, three days plus the inspector (248) do not fit beside the Plan panel, so tapping a block opens the inspector over the grid instead of docking (ED-167, ED-170). Shown open on R2-4.',
 '<b>Short tasks</b> (under 35 minutes, e.g. the 15-minute standup, the 30-minute call and dentist) are one-line pills, title 15 with a 24 or 28 dot. A 30-minute pill is 44 tall; a 15-minute pill’s tap area reaches 44 pt because no other block sits within reach (WCAG 2.5.8 spacing).',
 '<b>New values for your review</b> (nothing approved draws a touch grid): 96 px per hour, 180 minimum column, block title 17 / pill 15 under 35 minutes, dots 36 / 45 / 28 / 24.',
 '<b>Not on this board:</b> dragging (touch long-press is stage 2), the Mac drag from Inbox and the right-click menu (removed), Minimal (drawn on R2-1 at touch sizes), and medium windows (R2-1: the Today list; the editor floats there, R2-4).']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-2 · Today on expanded tablets: the Workspace at touch sizes</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Full on expanded tablets is the Workspace (Q1, ED-252) with the touch content scale (Q3, ED-256), inside the approved R2-1 navigation (ED-265, ED-267). Sample day and copy from E-FullA-v2. Frames at 75 %%. Dark on E-R2-2-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<div style="display: flex; gap: 36px; align-items: flex-start;"><ul style="width: 520px; flex: none; margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757;">%s</ul>'
        '<div style="display: flex; flex-direction: column; gap: 36px;">%s%s</div></div>') % (
            tag('th', 'Proposed · for owner review'), tag('tn', 'Light'), li, fr('ipad', 1180, 820, 'iPad Air · landscape 1180 × 820 · Full · Week (3 days fit)'), fr('and', 1280, 800, 'Android tablet · landscape 1280 × 800 · Full · Week (4 days fit)'))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-2</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1600px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1600,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-2.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-2</title>', '<title>E · R2-2 · Dark</title>').replace('Dark on E-R2-2-Dark.', 'Light on E-R2-2.').replace('>Light</span>', '>Dark</span>')
open('project/E-R2-2-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
