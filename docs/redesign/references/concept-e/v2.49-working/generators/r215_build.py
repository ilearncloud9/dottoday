import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP1 = open(L + 'E-Phones.dc.html', encoding='utf-8').read(); EP3 = open(L + 'E-Phones-3.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
def el(s, marker, tag='div'):
    i = s.index(marker); a = s.rfind('<' + tag, 0, i); return s[a:block(s, a, tag)]
def strip_grab(h): return re.sub(r'<div aria-hidden="true" style="[^"]*width: (36|32)px; height: (5|4)px;[^"]*"></div>', '', h)
def boxed(d, w, h):
    d = re.sub(r'position: absolute; left: 0; right: 0; (top: \d+px; bottom: 0;|bottom: 0; top: \d+px;|bottom: 0;)( z-index: \d+;)? border-radius: [^;]*;', 'position: relative; box-sizing: border-box; width: %dpx; height: %dpx; border-radius: 0;' % (w, h), d, count=1)
    d = re.sub(r'box-shadow: 0 -10px 40px rgba\(36,31,43,0\.2[02]\);', 'box-shadow: none;', d, count=1)
    return strip_grab(d)
ICI = boxed(el(frame_at(EP3, 18448), 'aria-label="Colour and icon"'), 380, 420)
IAC = boxed(el(frame_at(EP3, 37707), 'aria-label="All colours"'), 380, 520)
ACI = boxed(el(frame_at(EP3, 233043), 'aria-label="Colour and icon"'), 400, 430)
AAC = boxed(el(frame_at(EP3, 247124), 'aria-label="All colours"'), 400, 536)
ios_edit = el(frame_at(EP1, 414504), 'role="dialog" aria-label="Task editor"')
def as_panel(h, w, hgt):
    h = re.sub(r'position: absolute; left: 0; right: 0; top: 56px; bottom: 0;( z-index: \d+;)? border-radius: 38px 38px 0 0;', 'position: relative; box-sizing: border-box; width: %dpx; height: %dpx; border-radius: 0; overflow: hidden;' % (w, hgt), h, count=1)
    return strip_grab(h)
and_edit = frame_at(EP1, 113945)
def android_in_sheet(fr, sheet_h=772):
    fr = re.sub(r'<div aria-hidden="true" style="position: absolute; top: 12px; left: 198px; width: 16px; height: 16px; border-radius: 50%; background: #000; z-index: 20;"></div>', '', fr)
    fr = re.sub(r'^<div style="position: relative; width: 412px; height: 892px; border-radius: 44px; background: #FBF7F1; overflow: hidden; box-shadow:[^"]*;',
                '<div style="position: absolute; left: 0; top: -28px; width: 412px; height: %dpx; border-radius: 0; background: #FBF7F1; overflow: hidden; box-shadow: none;' % (sheet_h + 28), fr, count=1)
    return fr
POP = 'box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 18px 48px rgba(36,31,43,.22);'
def ipad_pop(content, left, top, w, h, arrow_y):
    return ('<div role="dialog" aria-label="Colour and icon, popover" style="position: absolute; left: %dpx; top: %dpx; width: %dpx; height: %dpx; border-radius: 26px; overflow: hidden; background: #FBF7F1; z-index: 40; %s">%s</div>'
            '<span aria-hidden="true" style="position: absolute; left: %dpx; top: %dpx; width: 22px; height: 22px; background: #FBF7F1; transform: rotate(45deg); border-radius: 4px; z-index: 41; box-shadow: 2px -2px 3px rgba(36,31,43,.10);"></span>') % (left, top, w, h, POP, content, left + w - 2, arrow_y - 11)
IPB = ipad_sidebar(FULL_ROWS, 'Plan') + workspace_inline(964, 796, ['Tue', 'Wed'], False, 420) + '<aside aria-label="Task editor, docked" style="position: absolute; right: 0; top: 24px; bottom: 0; width: 420px; z-index: 30; box-shadow: -1px 0 0 rgba(36,31,43,.10);">%s</aside>' % as_panel(ios_edit, 420, 796)
ANB = android_drawer(FULL_ROWS, 'Plan') + workspace_inline(1064, 772, ['Tue', 'Wed', 'Thu'], True, 412) + '<aside aria-label="Edit task" style="position: absolute; right: 0; top: 28px; bottom: 0; width: 412px; overflow: hidden; z-index: 30; box-shadow: -1px 0 0 rgba(36,31,43,.12);">%s</aside>' % android_in_sheet(and_edit)
F = {}
F['i1'] = device(1180, 820, IPB + ipad_pop(ICI, 372, 96, 380, 420, 132), False)
F['i2'] = device(1180, 820, IPB + ipad_pop(IAC, 372, 96, 380, 520, 132), False)
dialog = lambda c, w, h: ('<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 38;"></div><div role="dialog" aria-label="Colour and icon, M3 dialog" style="position: absolute; left: 50%%; top: 50%%; width: %dpx; height: %dpx; margin: %dpx 0 0 %dpx; border-radius: 28px; overflow: hidden; background: #FBF7F1; z-index: 40; box-shadow: 0 8px 28px rgba(36,31,43,.22);">%s</div>') % (w, h, -h // 2 + 14, -w // 2, c)
F['a1'] = device(1280, 800, ANB + dialog(ACI, 400, 430), True)
F['a2'] = device(1280, 800, ANB + dialog(AAC, 400, 536), True)
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note=''):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
ri = [fr('i1', 1180, 820, .5, '1 · Tap the task dot → Colour and icon popover', 'From the docked editor (R2-4), the approved Colour and icon sheet (ED-161) as a popover from the dot: the 12 colours, ⋯ All colours, current / suggested / recent icons, All icons. The editor stays live; the header recolours as you pick.'),
      fr('i2', 1180, 820, .5, '2 · ⋯ → All colours, in the same popover', 'Colour and Shade sliders, Dottoday colours and Your colours, pushed inside the popover; Done returns.')]
ra = [fr('a1', 1280, 800, .47, '1 · Colour and icon in an M3 dialog', 'Android has no popover: on expanded windows the approved Android sheet content opens as a centred M3 dialog over the Edit task side sheet.'),
      fr('a2', 1280, 800, .47, '2 · All colours in the same dialog', 'Pushed inside the dialog; Done returns.')]
notes = ['<b>The checklist rule, drawn:</b> “popover (as Mac and web) or the phone half sheet by width.” Expanded iPad: a popover; expanded Android: an M3 dialog (Android has no popover). Medium and compact: the approved phone half sheets.',
         '<b>Reused, not redrawn:</b> the approved Colour and icon and All colours sheets (E-Phones-3, ED-161) at phone sizes (the touch scale), boxed into the popover or dialog; the sheet grabbers are removed.',
         '<b>Data change still waits (ED-219 to ED-221):</b> “Your colours” and Custom… need a must-ask data change before they are built. Drawing them here does not approve that change.',
         '<b>Accessibility (approved, ED-161):</b> every swatch is a 44 pt / 48 dp target with a name; colour is never the only signal (the selected swatch has a check).']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
def row(title, frs): return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>' % (title, title, ''.join(frs))
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-15 · Colour and icon picker on tablets</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 3, fifth board. Dark on E-R2-15-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s%s') % (
            tag('th', 'Proposed · for owner review'), tag('tn', 'Light'), li, row('iPad', ri), row('Android tablet', ra))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-15</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1500px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1500,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-15.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('background: #EFE8EF;', 'background: #37313A;').replace('<title>E · R2-15</title>', '<title>E · R2-15 · Dark</title>').replace('Dark on E-R2-15-Dark.', 'Light on E-R2-15.').replace('<span class="tn">Light</span>', '<span class="tn">Dark</span>')
open('project/E-R2-15-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
