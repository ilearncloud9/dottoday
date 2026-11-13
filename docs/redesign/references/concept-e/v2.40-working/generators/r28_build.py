import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
from frames import today_pane
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
K = open(L + 'E-G4-7-States.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
def el(s, marker, tag='div'):
    i = s.index(marker); a = s.rfind('<' + tag, 0, i); return s[a:block(s, a, tag)]
def sheet_box(fr, w, h):
    d = el(fr, 'role="dialog" aria-modal="true"')
    d = re.sub(r'position: absolute; left: 0; right: 0; bottom: 0; height: \d+px; z-index: 41; border-radius: 34px 34px 0 0;', 'position: relative; width: %dpx; height: %dpx; border-radius: 0;' % (w, h), d, count=1)
    d = d.replace('box-shadow: 0 -8px 30px rgba(36,31,43,.16);', 'box-shadow: none;', 1)
    return re.sub(r'<div aria-hidden="true" style="[^"]*width: 36px; height: 5px;[^"]*"></div>', '', d)
SYNC = frame_at(K, 498698); CONF = frame_at(K, 827499); OFF = frame_at(K, 446998)
sync_sheet = lambda w, h: sheet_box(SYNC, w, h)
conf_sheet = lambda w, h: sheet_box(CONF, w, h)
banner = el(OFF, 'role="status" aria-live="polite"')
CLOUD_OFF = '<svg class="i" width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path d="M3 3l18 18"></path><path d="M8.5 6.2A6 6 0 0117.7 10H18a4 4 0 012.6 7"></path><path d="M16 19H7a4.5 4.5 0 01-1.8-8.6"></path></svg>'
SYNCI = '<svg class="i" width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path d="M20 11a8 8 0 00-14.3-4.9L4 8M4 3.5V8h4.5M4 13a8 8 0 0014.3 4.9L20 16M20 20.5V16h-4.5"></path></svg>'
BANG = '<span aria-hidden="true" style="width: 20px; height: 20px; border-radius: 10px; background: #241F2B; color: #FFFFFF; font: 800 12px/20px Manrope, system-ui; text-align: center; flex: none;">!</span>'
FOOT_RE = r'<div class="num" style="height: 32px; display: flex; align-items: center; gap: 6px; padding: 0 (12|16)px; font: ([^"]*); color: #6A6273;">\s*<span aria-hidden="true" style="width: 8px; height: 8px; border-radius: 50%; background: #11615C;"></span>Synced · 10:42</div>'
def foot(nav, icon, words, label, active=False):
    def rep(m):
        return ('<button aria-label="%s" aria-haspopup="dialog" style="height: 44px; border: 0; border-radius: 12px; display: flex; align-items: center; gap: 8px; padding: 0 %spx; text-align: left; font: %s; color: %s; %s">'
                '<span style="display: flex; color: #4E4757;">%s</span><span>%s</span></button>') % (label, m.group(1), m.group(2).replace('400 13px', '600 14px').replace('500 13px', '600 14px'), INK,
                                                                                                        'background: rgba(17,97,92,.14);' if active else 'background: transparent;', icon, words)
    out, n = re.subn(FOOT_RE, rep, nav, count=1); assert n == 1; return out
def ip_ws(): return workspace(964, 796, ['Tue', 'Wed', 'Thu'], False)
def an_ws(): return workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True)
def popover_left(content, left, top, w, h, arrow_y):
    return ('<div role="dialog" aria-label="Sync" style="position: absolute; left: %dpx; top: %dpx; width: %dpx; height: %dpx; border-radius: 26px; overflow: hidden; z-index: 40; '
            'box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 18px 48px rgba(36,31,43,.22);">%s</div>'
            '<span aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; width: 22px; height: 22px; background: #FFFDF9; transform: rotate(45deg); border-radius: 4px; z-index: 39;"></span>') % (left, top, w, h, content, left - 9, arrow_y, )
def side(content, w, modal, label):
    scrim = '<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 38;"></div>' if modal else ''
    rad = 'border-radius: 28px 0 0 28px; box-shadow: -8px 0 28px rgba(36,31,43,.14);' if modal else 'box-shadow: -1px 0 0 rgba(36,31,43,.12);'
    return scrim + '<aside aria-label="%s" style="position: absolute; right: 0; top: 28px; bottom: 0; width: %dpx; overflow: hidden; z-index: 40; background: #FFFDF9; %s">%s</aside>' % (label, w, rad, content)

W3 = '3 changes waiting to sync'
F = {}
nav_off = foot(ipad_sidebar(FULL_ROWS, 'Plan'), CLOUD_OFF, 'Offline · 3 waiting', 'Offline · changes saved here · 3 changes waiting to sync. Details')
F['i1'] = device(1180, 820, nav_off + ip_ws(), False)
nav_off_a = foot(ipad_sidebar(FULL_ROWS, 'Plan'), CLOUD_OFF, 'Offline · 3 waiting', 'Sync details', active=True)
F['i2'] = device(1180, 820, nav_off_a + ip_ws() + popover_left(sync_sheet(390, 360), 232, 440, 390, 360, 760), False)
nav_c = foot(ipad_sidebar(FULL_ROWS, 'Plan'), BANG, '1 change needs you', 'Sync: 1 change needs you. Review', active=True)
F['i3'] = device(1180, 820, nav_c + ip_ws() + popover_left(conf_sheet(390, 420), 232, 380, 390, 420, 760), False)
med_ip = ipad_top_tabs(['Today', 'Inbox', 'Calendar', 'Search'], 'Today', 820)
syncbtn = ('<button aria-label="%s" style="position: absolute; right: 176px; top: 34px; width: 44px; height: 44px; border: 0; border-radius: 22px; background: rgba(255,255,255,.66); '
           'box-shadow: inset 0 0 0 1px rgba(255,255,255,.6), 0 0 0 .5px rgba(36,31,43,.12), 0 8px 24px rgba(36,31,43,.10); color: #6A6273; display: flex; align-items: center; justify-content: center; z-index: 23;">%s'
           '<span aria-hidden="true" style="position: absolute; right: 2px; top: 2px; min-width: 18px; height: 18px; border-radius: 9px; background: #241F2B; color: #FFFFFF; font: 800 12px/18px Manrope, system-ui; text-align: center;">3</span></button>')
bn = banner.replace('position: absolute; top: 204px; left: 16px; right: 16px;', 'position: absolute; top: 96px; left: 40px; right: 40px;')
F['i4'] = device(820, 1180, med_ip + syncbtn % (W3, CLOUD_OFF) + bn + '<div style="position: absolute; left: 40px; top: 156px;">%s</div>' % today_pane(740), False)
navA_off = foot(android_drawer(FULL_ROWS, 'Plan'), CLOUD_OFF, 'Offline · 3 waiting', 'Offline · changes saved here · 3 changes waiting to sync. Details')
F['a1'] = device(1280, 800, navA_off + an_ws(), True)
F['a2'] = device(1280, 800, foot(android_drawer(FULL_ROWS, 'Plan'), CLOUD_OFF, 'Offline · 3 waiting', 'Sync details', active=True) + an_ws()
                 + side('<div style="padding-top: 8px;">%s</div>' % sync_sheet(380, 360), 380, False, 'Sync, standard side sheet'), True)
F['a3'] = device(1280, 800, foot(android_drawer(FULL_ROWS, 'Plan'), BANG, '1 change needs you', 'Sync: 1 change needs you. Review', active=True) + an_ws()
                 + side('<div style="padding-top: 8px;">%s</div>' % conf_sheet(380, 420), 380, True, 'Changed on two devices, modal side sheet'), True)
dbtn = ('<button aria-haspopup="menu" aria-label="Day menu" style="position: absolute; right: 24px; top: 52px; height: 48px; padding: 0 14px 0 18px; border: 0; border-radius: 24px; '
        'background: rgba(239,231,219,0.92); box-shadow: 0 1px 2px rgba(36,31,43,.14), 0 1px 3px 1px rgba(36,31,43,.08); display: flex; align-items: center; gap: 6px; font: 500 15px Roboto, system-ui, sans-serif; color: %s; z-index: 21;">Day%s</button>') % (INK, ic('chev', 18, 2.4))
rail = android_rail(['Today', 'Inbox', 'Calendar', 'Search'], 'Today')
rail = rail.replace('<a href="#" style="margin-top: auto;', ('<button aria-label="%s" style="margin-top: auto; position: relative; width: 56px; height: 48px; border: 0; background: transparent; color: #4E4757; display: flex; align-items: center; justify-content: center;">%s'
                    '<span aria-hidden="true" style="position: absolute; right: 6px; top: 4px; min-width: 18px; height: 18px; border-radius: 9px; background: #241F2B; color: #FFFFFF; font: 800 12px/18px Manrope, system-ui; text-align: center;">3</span></button>'
                    '<a href="#" style="') % (W3, CLOUD_OFF), 1)
bnA = banner.replace('position: absolute; top: 204px; left: 16px; right: 16px;', 'position: absolute; top: 112px; left: 120px; right: 32px;')
F['a4'] = device(800, 1280, rail + dbtn + bnA + '<div style="position: absolute; left: 120px; top: 170px;">%s</div>' % today_pane(648), True)

def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
ri = [fr('i1', 1180, 820, .42, '1 · Offline, 3 waiting', 'The state moves into the sidebar foot (icon + words), as the Mac sidebar line does (B5). No banner: the line is always in view.'),
      fr('i2', 1180, 820, .42, '2 · Tap the line → Sync', 'The approved Sync sheet content (B4) in a popover from the line: “Couldn’t sync…”, last synced, Sync now and its no-duplicate note.'),
      fr('i3', 1180, 820, .42, '3 · Conflict → review', '“1 change needs you” in the line; the approved review (C1/C2) in the popover: This device / Other device, Keep mine / Keep theirs. Resolved shows the R2-7 toast with Undo.'),
      fr('i4', 820, 1180, .3, '4 · Medium · no sidebar', 'As on phones: the offline banner under the top bar and a sync button with the “3” badge beside Day; it opens the same popover.')]
ra = [fr('a1', 1280, 800, .39, '1 · Offline, 3 waiting', 'Same line at the drawer foot.'),
      fr('a2', 1280, 800, .39, '2 · Sync in a standard side sheet', 'The same content in an M3 standard side sheet; the grid stays usable.'),
      fr('a3', 1280, 800, .39, '3 · Conflict review in a modal side sheet', 'Modal, because a choice is required before the detail is final; Back closes without choosing (nothing is lost).'),
      fr('a4', 800, 1280, .29, '4 · Medium · rail', 'The sync button with its badge sits above Settings in the rail; the banner sits over the Today list.')]
notes = ['<b>Tablets inherit every state</b> of the approved kit (ED-186 to ED-196): the vocabulary, wording, announcements and data-safety rules are unchanged. This board only places them.',
         '<b>Expanded = Mac pattern:</b> the sidebar or drawer foot carries the state (icon + words, never colour alone) and opens the detail. <b>Medium and compact = phone pattern:</b> banner + header sync button with badge.',
         '<b>Reused, not redrawn:</b> the iPhone Sync sheet (B4), the conflict review (C1/C2), the offline banner and badge (B2/B3), the R2-7 toast for the resolved Undo. Content at phone size = the touch scale (ED-256).',
         '<b>Not changed:</b> Sync now resends the same saved changes and never creates a second task; nothing is overwritten until you choose; “Keep both” for notes (ED-195) applies in the review as approved (drawn on E-G4-7-Q4-KeepBoth).']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
def row(title, frs): return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; gap: 24px; align-items: flex-start;">%s</div></section>' % (title, title, ''.join(frs))
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-8 · Sync states and conflicts on tablets</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 2, third board. The approved state kit (E-G4-7-States) says “tablets inherit every state; presentations in Round 2”: these are the presentations. Dark on E-R2-8-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s%s') % (
            tag('th', 'Proposed · for owner review'), tag('tn', 'Light'), li, row('iPad', ri), row('Android tablet', ra))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-8</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 2200px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2200,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-8.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-8</title>', '<title>E · R2-8 · Dark</title>').replace('Dark on E-R2-8-Dark.', 'Light on E-R2-8.').replace('>Light</span>', '>Dark</span>')
open('project/E-R2-8-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
