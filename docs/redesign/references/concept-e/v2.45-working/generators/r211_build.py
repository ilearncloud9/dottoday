import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP1 = open(L + 'E-Phones.dc.html', encoding='utf-8').read(); EP3 = open(L + 'E-Phones-3.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
def hide(fr, pat):
    while pat in fr:
        i = fr.index(pat); a = fr.rfind('<', 0, i); tag = re.match(r'<(\w+)', fr[a:]).group(1); fr = fr[:a] + fr[block(fr, a, tag):]
    return fr
def pane(fr, w, h, top, ph):
    """A phone screen as a tablet pane: bezel, island, status and tab bar removed; width widened (rows use left/right insets)."""
    fr = re.sub(r'^<div style="position: relative; width: (390|412)px; height: (\d+)px; border-radius: \d+px;([^"]*?)box-shadow:[^;"]*(;[^"]*)?"',
                lambda m: '<div style="position: absolute; left: 0; top: %dpx; width: %dpx; height: %dpx; border-radius: 0;%s"' % (-top, w, ph, m.group(3)), fr, count=1)
    for pat in ('aria-label="Main"', 'aria-label="Add a task', 'border-radius: 25px; background: #000;', 'border-radius: 50%; background: #000;'):
        fr = hide(fr, pat)
    fr = re.sub(r'<div aria-hidden="true" style="position: absolute; bottom: 8px; left: \d+px; width: \d+px; height: [45]px;[^"]*"></div>', '', fr)
    return '<div style="position: relative; width: %dpx; height: %dpx; overflow: hidden; background: %s;">%s</div>' % (w, h, GROUND, fr)
IR, IYD = frame_at(EP1, 255949), frame_at(EP1, 267433)
IAP = frame_at(EP3, 118899)
AR, AWU = frame_at(EP1, 275911), frame_at(EP1, 286633)
AAP = frame_at(EP3, 285448)
def sel(fr, label):
    """Mark the open group in the list pane (tint), as a list-detail selection."""
    i = fr.find('>%s<' % label)
    if i < 0: return fr
    a = fr.rfind('<button', 0, i); b = fr.rfind('<a ', 0, i); c = fr.rfind('<div role="listitem"', 0, i); a = max(a, b, c)
    if a < 0: return fr
    j = fr.index('style="', a) + 7
    return fr[:j] + 'background: rgba(17,97,92,.12); border-radius: 14px; ' + fr[j:]
def split(nav, list_html, detail_html, w, h, top, lw):
    return device(w, h, nav + ('<div style="position: absolute; left: 216px; top: %dpx; width: %dpx; bottom: 0; box-shadow: 1px 0 0 rgba(36,31,43,.10); z-index: 2;">%s</div>'
                               '<div style="position: absolute; left: %dpx; right: 0; top: %dpx; bottom: 0;">%s</div>') % (top, lw, list_html, 216 + lw, top, detail_html), w > 1200)
def settings_nav(android):
    n = android_drawer(FULL_ROWS, 'Plan') if android else ipad_sidebar(FULL_ROWS, 'Plan')
    n = n.replace(' aria-current="page"', '').replace('background: rgba(17,97,92,.14);', '').replace('background: #CFE8E4;', '')
    j = n.rfind('<span>Settings</span>'); a = n.rfind('style="', 0, j) + 7
    return n[:a] + ('background: #CFE8E4; ' if android else 'background: rgba(17,97,92,.14); ') + n[a:]
def noback(fr):
    fr = fr.replace('>‹ Settings<', '><')
    fr = fr.replace('<span style="width: 48px; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 22px;">←</span>', '<span style="width: 8px;"></span>')
    fr = re.sub(r'<button aria-label="(Back|Navigate up)"[^>]*>.*?</button>', '<span style="width: 8px;"></span>', fr, count=1, flags=re.S)
    return fr
IYD, IAP, AWU, AAP = noback(IYD), noback(IAP), noback(AWU), noback(AAP)
F = {}
iw, ih, it = 964, 796, 24
F['i1'] = split(settings_nav(False), pane(sel(IR, 'Your day'), 380, ih, 30, 844), pane(IYD, iw - 380, ih, 30, 844), 1180, 820, it, 380)
F['i2'] = split(settings_nav(False), pane(sel(IR, 'Appearance'), 380, ih, 30, 844), pane(IAP, iw - 380, ih, 30, 844), 1180, 820, it, 380)
aw = 1064
F['a1'] = device(1280, 800, settings_nav(True) + ('<div style="position: absolute; left: 216px; top: 28px; width: 412px; bottom: 0; box-shadow: 1px 0 0 rgba(36,31,43,.10); z-index: 2;">%s</div>'
                 '<div style="position: absolute; left: 628px; right: 0; top: 28px; bottom: 0;">%s</div>') % (pane(sel(AR, 'Your day'), 412, 772, 28, 892), pane(AWU, aw - 412, 772, 28, 892)), True)
F['a2'] = device(1280, 800, settings_nav(True) + ('<div style="position: absolute; left: 216px; top: 28px; width: 412px; bottom: 0; box-shadow: 1px 0 0 rgba(36,31,43,.10); z-index: 2;">%s</div>'
                 '<div style="position: absolute; left: 628px; right: 0; top: 28px; bottom: 0;">%s</div>') % (pane(sel(AR, 'Appearance'), 412, 772, 28, 892), pane(AAP, aw - 412, 772, 28, 892)), True)
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
ri = [fr('i1', 1180, 820, .55, '1 · Settings › Your day', 'Settings at the sidebar foot opens two panes: the approved root (account, Synced, search, six groups) on the left, the chosen group on the right.'),
      fr('i2', 1180, 820, .55, '2 · Settings › Appearance', 'The approved Appearance page (ED-161) as the detail: Layout with its live preview, Theme, App colour, Format.')]
ra = [fr('a1', 1280, 800, .5, '1 · Settings › Your day › Wake Up and Wind Down', 'M3 list-detail: the approved Android root on the left, the approved Wake Up and Wind Down page on the right.'),
      fr('a2', 1280, 800, .5, '2 · Settings › Appearance', 'The approved Android Appearance page as the detail.')]
notes = ['<b>Two panes on expanded, the phone stack below:</b> the register’s G2-4 line (“two-pane Settings”) drawn. Expanded: the list stays on the left and the chosen group fills the right; the sidebar keeps Settings selected at its foot (R2-1). Medium and compact: the approved phone screens, pushed one at a time.',
         '<b>Reused unchanged:</b> the approved root, Your day, Wake Up and Wind Down and Appearance pages from E-Phones and E-Phones-3, at phone sizes (the touch scale, ED-256), widened to their pane. Nothing new; same six groups, search, account row and Synced line.',
         '<b>Selection:</b> the open group is tinted in the list (Your day, Appearance). In two panes the group page drops its ‹ Settings / ← control; it returns in the stacked layout.',
         '<b>Mac stays its own Settings window</b> (ED-081). Not drawn again here: the remaining group pages (Planning, Reminders, Data and privacy, Help and about) follow the same two-pane rule.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
def row(title, frs): return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>' % (title, title, ''.join(frs))
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-11 · Settings on tablets</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 3, first board (supporting experiences). Dark on E-R2-11-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s%s') % (
            tag('th', 'Proposed · for owner review'), tag('tn', 'Light'), li, row('iPad', ri), row('Android tablet', ra))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-11</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1500px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1500,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-11.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
def theme_for_dark(h):
    """In the dark board the app is in Dark: Dark is the chosen theme; each preview tile keeps its own theme's colours."""
    def btn(label, h):
        out = []
        for m in re.finditer(r'<button role="radio" aria-checked="(true|false)" aria-label="%s".*?</button>' % label, h, re.S):
            out.append(m)
        return out
    for m in reversed(btn('Light', h)):
        b = m.group(0).replace('aria-checked="true"', 'aria-checked="false"').replace('box-shadow: 0 0 0 2px #11615C;', 'box-shadow: 0 0 0 1px rgba(36,31,43,.18);')
        b = re.sub(r'font: 700 15px ([^;]*); color: #11615C; padding: 2px 10px; border-radius: 12px; box-shadow: 0 0 0 1.5px #11615C;', r'font: 600 15px \1; color: #241F2B; padding: 2px 10px; border-radius: 12px; ', b)
        b = b.replace('background: #FBF7F1;', 'background: @@LG@@;').replace('background: #FFFDF9;', 'background: @@LS@@;')
        h = h[:m.start()] + b + h[m.end():]
    h = h.replace('linear-gradient(135deg, #FBF7F1 0 50%, #1E1B22 50% 100%)', 'linear-gradient(135deg, @@LG@@ 0 50%, @@DG@@ 50% 100%)')  # Auto: half light, half dark in every theme
    for m in reversed(btn('Dark', h)):
        b = m.group(0).replace('aria-checked="false"', 'aria-checked="true"').replace('box-shadow: 0 0 0 1px rgba(36,31,43,.18);', 'box-shadow: 0 0 0 2px #11615C;', 1)
        b = re.sub(r'font: 600 15px ([^;]*); color: #241F2B; padding: 2px 10px; border-radius: 12px; ', r'font: 700 15px \1; color: #11615C; padding: 2px 10px; border-radius: 12px; box-shadow: 0 0 0 1.5px #11615C;', b)
        b = b.replace('background: #1E1B22;', 'background: @@DG@@;').replace('background: #2A2630;', 'background: @@DS@@;')
        h = h[:m.start()] + b + h[m.end():]
    return h
dark = darkify(theme_for_dark(page)).replace('class="blk-d', 'class="blk').replace('<title>E · R2-11</title>', '<title>E · R2-11 · Dark</title>').replace('Dark on E-R2-11-Dark.', 'Light on E-R2-11.').replace('<span class="tn">Light</span>', '<span class="tn">Dark</span>')
dark = dark.replace('@@LG@@', '#FBF7F1').replace('@@LS@@', '#FFFDF9').replace('@@DG@@', '#1E1B22').replace('@@DS@@', '#2A2630')
open('project/E-R2-11-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
