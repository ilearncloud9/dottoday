import re, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
H = int(sys.argv[1])
from frames import *

TABS = ['Today', 'Inbox', 'Calendar', 'Search']; MTABS = ['Now', 'Inbox', 'Calendar', 'Search']
MIN1280 = touch(phone(raw('Minimal · 1280 × 800 (approved reference)')))
def wide(src, w, h, top, nav):
    return place(swap_nav(src, nav), w, h, top, (1180 - w) // 2 if w < 1180 else 0)

F = {}
F['ipad_full_x'] = device(1180, 820, wide(touch(raw('Full · 1160 × 800, inspector docked (248)')), 1160, 796, 24, ipad_sidebar(FULL_ROWS, 'Plan')), False)
med = ipad_top_tabs(TABS, 'Today', 820) + '<div style="position: absolute; left: 40px; top: 100px;">%s</div>' % today_pane(740)
F['ipad_full_m'] = device(820, 1180, med, False)
F['ipad_full_m_sb'] = device(820, 1180, med + '<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.18); z-index: 24;"></div>'
                             + ipad_sidebar(FULL_ROWS, 'Today', top=24, h=1156, width=320), False)
F['ipad_min_x'] = device(1180, 820, wide(MIN1160, 1160, 796, 24, ipad_sidebar(MIN_ROWS, 'Now', width=200)), False)
F['ipad_min_m'] = device(820, 1180, ipad_top_tabs(MTABS, 'Now', 820, day=False) + minimal_stack(670, 75, 92, 690), False)
# Split View ½ in landscape: Dottoday's window is 590 wide -> compact -> the phone layout exactly (ED-104, ED-171)
i = [m.start() for m in re.finditer(r'<div style="position: relative; width: 390px; height: 844px;', PHONES)]
ph = None
for a0 in i:
    b0 = PHONES[a0:block(PHONES, a0, 'div')]
    if 'aria-label="Tuesday timeline"' in b0 and 'Hold a dot to select several tasks' in b0:
        ph = b0; break
assert ph
sc = 1.47
split = ('<div style="position: absolute; left: 0; top: 24px; width: 586px; bottom: 0; overflow: hidden; background: %s;">'
         '<div style="position: absolute; left: 0; top: -60px; width: 586px; height: 856px;">%s</div></div>'
         '<div aria-hidden="true" style="position: absolute; left: 586px; top: 24px; bottom: 0; width: 8px; background: #241F2B;"><span style="position: absolute; left: 2px; top: 50%%; width: 4px; height: 44px; margin-top: -22px; border-radius: 2px; background: #8A8494;"></span></div>'
         '<div style="position: absolute; left: 594px; right: 0; top: 24px; bottom: 0; background: #ECE8EE; display: flex; align-items: center; justify-content: center; font: 600 16px -apple-system, system-ui, sans-serif; color: %s;">Another app</div>') % (GROUND, ph.replace('width: 390px; height: 844px;', 'width: 586px; height: 856px;', 1), SEC)
F['ipad_split'] = device(1180, 820, split, False)
F['and_full_x'] = device(1280, 800, wide(touch(raw('Full · 1280 × 800 (approved reference)')), 1280, 772, 28, android_drawer(FULL_ROWS, 'Plan')), True)
dbtn = ('<button aria-haspopup="menu" aria-label="Day menu" style="position: absolute; right: 24px; top: 52px; height: 48px; padding: 0 14px 0 18px; border: 0; border-radius: 24px; '
        'background: rgba(239,231,219,0.92); box-shadow: 0 1px 2px rgba(36,31,43,.14), 0 1px 3px 1px rgba(36,31,43,.08); display: flex; align-items: center; gap: 6px; font: 500 15px Roboto, system-ui, sans-serif; color: %s; z-index: 21;">Day%s</button>') % (INK, ic('chev', 18, 2.4))
F['and_full_m'] = device(800, 1280, android_rail(TABS, 'Today') + dbtn + '<div style="position: absolute; left: 120px; top: 60px;">%s</div>' % today_pane(648), True)
F['and_min_x'] = device(1280, 800, wide(MIN1280, 1280, 772, 28, android_drawer(MIN_ROWS, 'Now', width=200)), True)
crease = '<div aria-hidden="true" style="position: absolute; left: 50%; top: 0; bottom: 0; width: 0; border-left: 1px dashed rgba(36,31,43,.22); z-index: 29;"></div>'
F['fold'] = device(700, 840, android_rail(TABS, 'Today') + dbtn.replace('top: 52px', 'top: 44px') + '<div style="position: absolute; left: 112px; top: 44px;">%s</div>' % today_pane(564) + crease, True)

SC = 0.5
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, label, note=''):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px;"><figcaption style="font: 700 14px Manrope; color: #4E4757; max-width: %dpx;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>%s</figure>'
            % (w * SC + 14, label, w * SC + 14, h * SC + 14, w, h, SC, F[key],
               ('<div style="font-size: 12.5px; line-height: 18px; color: #4E4757; max-width: %dpx;">%s</div>' % (w * SC + 14, note)) if note else ''))
def row(title, tags, notes, frames):
    li = ''.join('<li style="margin: 0 0 6px;">%s</li>' % n for n in notes)
    return ('<section aria-label="%s" style="display: flex; gap: 32px; align-items: flex-start;"><div style="width: 420px; flex: none; display: flex; flex-direction: column; gap: 10px;">'
            '<div style="font: 700 22px Manrope;">%s</div><div style="display: flex; flex-wrap: wrap; gap: 6px;">%s</div><ul style="margin: 4px 0 0; padding-left: 18px; font-size: 14px; line-height: 21px; color: #4E4757;">%s</ul></div>'
            '<div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>' % (title, title, tags, li, ''.join(frames)))
rows = [
 row('1 · iPad · Full', tag('td', 'ED-171 · ED-252') + tag('tn', 'Same structure as Mac and web at each width'), [
   '<b>Expanded (≥ 840):</b> the iPadOS sidebar, a floating glass panel, with the Workspace’s own list (Today, Plan with Inbox, Routines and Brain dump, Calendar views, Review, Search) at 44 pt rows. Settings and Synced sit at its foot; Settings is never a tab.',
   '<b>Medium (600–839):</b> the iPadOS top tab bar with the four main places (Today · Inbox · Calendar · Search). The sidebar button on the left opens the same list over the content, so Plan, Routines, Review and Settings stay one tap away. Day ▾ and + sit on the right.',
   'The Workspace content in frame 1a is still drawn at Mac sizes; its touch version (ED-256) is board R2-2. Keyboard hints and the Mac right-click menu are removed on touch.'],
   [fr('ipad_full_x', 1180, 820, '1a · Expanded · iPad Air landscape 1180 × 820'), fr('ipad_full_m', 820, 1180, '1b · Medium · iPad Air portrait 820 × 1180'),
    fr('ipad_full_m_sb', 820, 1180, '1c · Medium · sidebar opened from the tab bar')]),
 row('2 · iPad · Minimal', tag('td', 'ED-171 · ED-254 · ED-256') + tag('th', 'Question R2-1a'), [
   '<b>Expanded:</b> E-Minimal at the touch sizes, with Minimal’s own sidebar (Now, Inbox, Calendar, Search) and Settings at the foot.',
   '<b>Medium portrait:</b> top tabs, then Now above the Day list (the Day column has room below, not beside). The Day menu stays in the Day header, as on E-Minimal.',
   '<b>Question R2-1a:</b> medium tablets here use E-Minimal’s places (Now · Inbox · Calendar · Search), by width as in Q2. The tablet checklist listed the phones’ set (Now · Today · Inbox). Recommended: by width.',
   '<b>Compact (Split View ½, Slide Over):</b> the phone layout exactly, with the iPhone tab bar at the bottom (ED-104).'],
   [fr('ipad_min_x', 1180, 820, '2a · Expanded · 1180 × 820'), fr('ipad_min_m', 820, 1180, '2b · Medium · portrait 820 × 1180'),
    fr('ipad_split', 1180, 820, '2c · Compact · Split View ½ (590 wide)', 'Shown with Full’s phone Today; Minimal’s phone Today behaves the same.')]),
 row('3 · Android tablet · Full', tag('td', 'ED-171 · ED-252'), [
   '<b>Expanded:</b> an M3 navigation drawer with the same list as the iPad sidebar, 48 dp items and the teal pill; Settings and Synced at the foot. The menu button collapses it to the rail.',
   '<b>Medium:</b> the M3 navigation rail: menu (opens the drawer), the + as the rail’s FAB, Today · Inbox · Calendar · Search, and Settings at the bottom. Day is a frosted button, top right.',
   'The Workspace content in 3a is at Mac sizes until R2-2.'],
   [fr('and_full_x', 1280, 800, '3a · Expanded · 1280 × 800'), fr('and_full_m', 800, 1280, '3b · Medium · portrait 800 × 1280')]),
 row('4 · Android · Minimal and foldable', tag('td', 'ED-168 · ED-171'), [
   '<b>Expanded Minimal:</b> E-Minimal at touch sizes with the drawer (Now, Inbox, Calendar, Search, Settings at the foot).',
   '<b>Foldable, unfolded (700 × 840, medium):</b> the rail, as any medium window. Flat, the content spans the fold (dashed line, not drawn on the device). Half-open in tabletop it becomes H1 compact (ED-168); folded it is the phone.'],
   [fr('and_min_x', 1280, 800, '4a · Expanded · Minimal · 1280 × 800'), fr('fold', 700, 840, '4b · Foldable unfolded · Full · 700 × 840')]),
]
hd = ('<header style="display: flex; flex-direction: column; gap: 8px; max-width: 2100px;">'
      '<h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-1 · Tablet navigation shell (iPad, Android tablet, foldable)</h1>'
      '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 1 of Round 2 (ED-264). How each width class moves between places on tablets: sidebar when expanded, iPad top tabs or the Android rail at medium, the phone layout when compact. '
      'Built from the approved windows (E-G4-3-Narrow), the ED-256 touch transform and E-Phones. Frames at 50 %%. Dark is on E-R2-1-Dark. For owner review; nothing is approved.</p>'
      '<div style="display: flex; gap: 6px;">%s %s</div></header>') % (tag('th', 'Proposed · for owner review'), tag('tn', 'Light'))
def page(body_rows, title, dark=False):
    return ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>%s</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' % title
            + AB['helmet'] + '\n<div style="width: 2240px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
            + hd + '\n' + '\n'.join(body_rows) + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2240,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
light = page(rows, 'E · R2-1')
open('project/E-R2-1.dc.html', 'w', encoding='utf-8').write(light)
sys.path.insert(0, 'h')
from darkify import darkify
dark = darkify(light).replace('class="blk-d', 'class="blk').replace('<title>E · R2-1</title>', '<title>E · R2-1 · Dark</title>').replace('Dark is on E-R2-1-Dark.', 'Light is on E-R2-1.').replace('>Light</span>', '>Dark</span>')
open('project/E-R2-1-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
