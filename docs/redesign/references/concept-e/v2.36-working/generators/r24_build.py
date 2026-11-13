import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
from frames import today_pane
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP1 = open(L + 'E-Phones.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
def el(s, marker, tag='div'):
    i = s.index(marker); a = s.rfind('<' + tag, 0, i); return s[a:block(s, a, tag)]
ios_edit = el(frame_at(EP1, 414504), 'role="dialog" aria-label="Task editor"')
and_edit = frame_at(EP1, 113945)
def as_panel(h, w, hgt):
    h = re.sub(r'position: absolute; left: 0; right: 0; top: 56px; bottom: 0;( z-index: \d+;)? border-radius: 38px 38px 0 0;', 'position: relative; box-sizing: border-box; width: %dpx; height: %dpx; border-radius: 0; overflow: hidden;' % (w, hgt), h, count=1)
    return re.sub(r'<div aria-hidden="true" style="[^"]*width: 36px; height: 5px;[^"]*"></div>', '', h)
def android_in_sheet(fr, sheet_h=772):
    fr = re.sub(r'<div aria-hidden="true" style="position: absolute; top: 12px; left: 198px; width: 16px; height: 16px; border-radius: 50%; background: #000; z-index: 20;"></div>', '', fr)
    fr = re.sub(r'^<div style="position: relative; width: 412px; height: 892px; border-radius: 44px; background: #FBF7F1; overflow: hidden; box-shadow:[^"]*;', '<div style="position: absolute; left: 0; top: -28px; width: 412px; height: %dpx; border-radius: 0; background: #FBF7F1; overflow: hidden; box-shadow: none;' % (sheet_h + 28), fr, count=1)
    kb = '<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 300px; background: #ECE6EE;'
    if kb in fr:
        a = fr.index(kb); fr = fr[:a] + fr[block(fr, a, 'div'):]
    return fr
# Mac Workspace inspector (approved, E-G4-3-Narrow 1160) at ×1.3 for the comparison
insp = el(raw('Full · 1160 × 800, inspector docked (248)'), 'aria-label="Inspector: Deep work: roadmap"', 'aside')
insp = re.sub(r'<kbd[^>]*>[^<]*</kbd>', '', insp)
def floating_inspector(left, top):
    return ('<div role="dialog" aria-label="Inspector, floating" style="position: absolute; left: %dpx; top: %dpx; width: 248px; height: 520px; zoom: 1.3; border-radius: 18px; overflow: hidden; z-index: 40; '
            'box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 18px 48px rgba(36,31,43,.22);">%s</div>') % (left, top, insp.replace('<aside ', '<aside style="height: 100%;" ', 1) if False else insp)

IP_A = device(1180, 820, ipad_sidebar(FULL_ROWS, 'Plan') + workspace(964, 796, ['Tue', 'Wed', 'Thu'], False) + floating_inspector(610 / 1.3 * 1.0, 96 / 1.3 * 1.0), False)
IP_B = device(1180, 820, ipad_sidebar(FULL_ROWS, 'Plan') + workspace_inline(964, 796, ['Tue', 'Wed'], False, 420)
              + '<aside aria-label="Task editor, docked" style="position: absolute; right: 0; top: 24px; bottom: 0; width: 420px; z-index: 30; box-shadow: -1px 0 0 rgba(36,31,43,.10);">%s</aside>' % as_panel(ios_edit, 420, 796), False)
AN_A = device(1280, 800, android_drawer(FULL_ROWS, 'Plan') + workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True) + floating_inspector(760 / 1.3, 100 / 1.3), True)
AN_B = device(1280, 800, android_drawer(FULL_ROWS, 'Plan') + workspace_inline(1064, 772, ['Tue', 'Wed', 'Thu'], True, 412)
              + '<aside aria-label="Edit task, standard side sheet" style="position: absolute; right: 0; top: 28px; bottom: 0; width: 412px; overflow: hidden; z-index: 30; box-shadow: -1px 0 0 rgba(36,31,43,.12);">%s</aside>' % android_in_sheet(and_edit), True)
# medium: the editor floats (ED-167, ED-259)
med_ip = ipad_top_tabs(['Today', 'Inbox', 'Calendar', 'Search'], 'Today', 820) + '<div style="position: absolute; left: 40px; top: 100px;">%s</div>' % today_pane(740)
MED_IP = device(820, 1180, med_ip + '<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.16); z-index: 34;"></div>'
                + '<div role="dialog" aria-label="Task editor, floating" style="position: absolute; left: 50%%; margin-left: -215px; top: 92px; width: 430px; height: 1040px; border-radius: 28px; overflow: hidden; z-index: 40; '
                  'box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 24px 60px rgba(36,31,43,.25);">%s</div>' % as_panel(ios_edit, 430, 1040), False)
dbtn = ('<button aria-haspopup="menu" aria-label="Day menu" style="position: absolute; right: 24px; top: 52px; height: 48px; padding: 0 14px 0 18px; border: 0; border-radius: 24px; '
        'background: rgba(239,231,219,0.92); box-shadow: 0 1px 2px rgba(36,31,43,.14), 0 1px 3px 1px rgba(36,31,43,.08); display: flex; align-items: center; gap: 6px; font: 500 15px Roboto, system-ui, sans-serif; color: %s; z-index: 21;">Day%s</button>') % (INK, ic('chev', 18, 2.4))
MED_AN = device(800, 1280, android_rail(['Today', 'Inbox', 'Calendar', 'Search'], 'Today') + dbtn + '<div style="position: absolute; left: 120px; top: 60px;">%s</div>' % today_pane(648)
                + '<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 38;"></div>'
                + '<aside aria-label="Edit task, modal side sheet" style="position: absolute; right: 0; top: 28px; bottom: 0; width: 412px; border-radius: 28px 0 0 28px; overflow: hidden; z-index: 40; box-shadow: -8px 0 28px rgba(36,31,43,.14);">%s</aside>' % android_in_sheet(and_edit, 1252), True)

SC = 0.55
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(html, w, h, label, note, sc=SC):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 14, label, w * sc + 14, h * sc + 14, w, h, sc, html, note)
def opt(title, tags, notes, frames):
    li = ''.join('<li style="margin: 0 0 6px;">%s</li>' % n for n in notes)
    return ('<section aria-label="%s" style="display: flex; gap: 32px; align-items: flex-start;"><div style="width: 430px; flex: none; display: flex; flex-direction: column; gap: 10px;">'
            '<div style="font: 700 22px Manrope;">%s</div><div style="display: flex; flex-wrap: wrap; gap: 6px;">%s</div><ul style="margin: 4px 0 0; padding-left: 18px; font-size: 14px; line-height: 21px; color: #4E4757;">%s</ul></div>'
            '<div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>') % (title, title, tags, li, ''.join(frames))
rows = [
 opt('A · The Workspace inspector, floating', tag('tn', 'Not chosen · kept as history') + tag('tn', 'As on Mac at this width (ED-170)'), [
   'Tapping a block opens the Mac inspector (248) over the grid; it cannot dock beside three days at touch sizes.',
   'Drawn here at ×1.3 for comparison only; a touch version would need its own sizes.',
   'Conflicts with ED-086, which gives the iPad the option D editor; Android has no approved inspector.'],
   [fr(IP_A, 1180, 820, 'A1 · iPad · 1180 × 820', ''), fr(AN_A, 1280, 800, 'A2 · Android tablet · 1280 × 800', '')]),
 opt('B · The option D editor, docked beside the grid', tag('tb', 'Chosen · ED-273') + tag('td', 'ED-086 · ED-167 · ED-259') + tag('tn', 'One task surface'), [
   'Tapping a block docks the approved full editor (ED-086) at the right, 420 wide: header in the task colour, Done · Move · Shift the rest · Focus, When, alerts, Repeat, Energy, steps and notes.',
   'It docks because the window allows it (≥ 1160 with sidebar 216, the grid ≥ 480 and the editor 420, ED-168): the grid narrows to the days that fit and the Plan panel steps aside (ED-184).',
   'Android: the approved Edit task in an M3 standard side sheet, beside the grid.',
   'Same editor as iPhone and Android phones; nothing new to design or build.'],
   [fr(IP_B, 1180, 820, 'B1 · iPad · editor docked', ''), fr(AN_B, 1280, 800, 'B2 · Android tablet · Edit task in a standard side sheet', '')]),
 opt('Medium windows · the editor floats (both options)', tag('td', 'ED-167 · ED-259'), [
   'Below 1160 the same editor floats: on iPad over the Today list (dimmed slightly), on Android in an M3 modal side sheet from the right.',
   'Changing width never saves, discards or resets the editor (ED-168).',
   'Compact windows keep the phone sheets (iPhone detents, Android partial sheet).'],
   [fr(MED_IP, 820, 1180, 'M1 · iPad portrait 820 × 1180 · floating editor', ''), fr(MED_AN, 800, 1280, 'M2 · Android portrait 800 × 1280 · modal side sheet', '')]),
]
hd = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-4 · Edit on tablets: which task surface, docked or floating</h1>'
      '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 1, step “Edit” (ED-166). <b>Question R2-4a:</b> on expanded tablets the Workspace (Q1) meets two approved task surfaces: the Mac inspector (ED-170) and the iPad option D editor (ED-086, docking per Q5 / ED-259). '
      'A and B show both on the approved touch Workspace (R2-2). <b>Decided: B (ED-273).</b> Editors reused from E-Phones (iPhone full editor, Android Edit task). Frames at 55 %%. Dark on E-R2-4-Dark. Approved by the owner, 13 Nov 2026 (ED-274).</p>'
      '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('tb', 'Approved · ED-274'), tag('tb', 'R2-4a decided · B'), tag('tn', 'Light'))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-4</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 2160px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 40px;">\n' % H
        + hd + '\n' + '\n'.join(rows) + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2160,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-4.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-4</title>', '<title>E · R2-4 · Dark</title>').replace('Dark on E-R2-4-Dark.', 'Light on E-R2-4.').replace('>Light</span>', '>Dark</span>')
open('project/E-R2-4-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
