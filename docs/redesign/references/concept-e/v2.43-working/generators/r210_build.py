import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
def groups(apple):
    def k(key, shift=False): return (('⇧' if shift else '') + '⌘' + key) if apple else ('Ctrl+' + ('Shift+' if shift else '') + key)
    return [('Everywhere', [(k('N'), 'Add a task'), (k('1'), 'Go to Today'), (k('2'), 'Go to Inbox'), (k('3'), 'Go to Week'), (k('4'), 'Go to Month'), (k('Z'), 'Undo the last change'), (k('Z', True), 'Redo what was undone'), (k('/'), 'Show these shortcuts')]),
            ('Today', [(k('←'), 'Previous day'), (k('→'), 'Next day'), (k('T'), 'Back to today'), (k('D'), 'Mark the current task done'), ('↑ ↓', 'Pick the previous or next task'), (k('↑') + ' ' + k('↓'), 'Move the picked tasks 5 min earlier or later'),
                       (k('↑', True) + ' ' + k('↓', True), 'Move the picked tasks 15 min earlier or later'), ('Delete', 'Move the picked tasks to Trash'), ('↩', 'Open the picked task'), ('Space', 'Mark the picked task done')]),
            ('Week and Month', [(k('←'), 'Previous week or month'), (k('→'), 'Next week or month'), (k('T'), 'This week or month')]),
            ('Inbox', [(k('↩'), 'Place the selected task in its first free slot'), (k('P', True), 'Auto-plan the week')]),
            ('Editing a task', [(k('S'), 'Save and close'), (k('D'), 'Mark done'), ('esc', 'Close')])]
def kbd(t, font): return ''.join('<kbd style="display: inline-block; min-width: 26px; padding: 2px 7px; border-radius: 7px; background: #F1ECE4; box-shadow: inset 0 -1.5px 0 rgba(36,31,43,.14); font: 600 13px/20px %s; color: %s; text-align: center; margin-left: 4px;">%s</kbd>' % (font, INK, p) for p in t.split(' '))
def grp(cap, rows, font):
    r = ''.join('<div style="display: flex; align-items: center; justify-content: space-between; gap: 12px; min-height: 34px; border-top: 1px solid rgba(36,31,43,.06);"><span style="font: 500 14px/18px Manrope;">%s</span><span style="white-space: nowrap;">%s</span></div>' % (a, kbd(k, font)) for k, a in rows)
    return '<section aria-label="%s" style="break-inside: avoid; margin-bottom: 14px;"><div role="heading" style="font: 700 12px Manrope; letter-spacing: .8px; color: %s; margin-bottom: 4px;">%s</div>%s</div>' % (cap, SEC, cap.upper(), r) .replace('</div>', '</section>', 0)
def sheet(apple, w, h, font):
    gs = groups(apple)
    body = ''.join('<section aria-label="%s" style="break-inside: avoid; margin-bottom: 16px;"><div role="heading" style="font: 700 12px Manrope; letter-spacing: .8px; color: %s; margin-bottom: 4px;">%s</div>%s</section>' % (
        c, SEC, c.upper(), ''.join('<div style="display: flex; align-items: center; justify-content: space-between; gap: 12px; min-height: 34px; border-top: 1px solid rgba(36,31,43,.06);"><span style="font: 500 14px/18px Manrope;">%s</span><span style="white-space: nowrap;">%s</span></div>' % (a, kbd(k, font)) for k, a in rows)) for c, rows in gs)
    return ('<div role="dialog" aria-label="Keyboard shortcuts" style="width: %dpx; height: %dpx; box-sizing: border-box; border-radius: 26px; background: %s; box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 24px 60px rgba(36,31,43,.25); padding: 18px 24px; overflow: hidden; font-family: Manrope; color: %s;">'
            '<div style="display: flex; align-items: center; justify-content: space-between; height: 44px;"><span role="heading" style="font: 800 22px Manrope;">Keyboard shortcuts</span>'
            '<button aria-label="Close" style="width: 44px; height: 44px; border: 0; border-radius: 22px; background: #F1ECE4; color: %s; font: 600 18px Manrope;">✕</button></div>'
            '<div style="columns: 2; column-gap: 32px; margin-top: 10px;">%s</div></div>') % (w, h, GROUND, INK, INK, body)
def scrim(a=.32): return '<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,%s); z-index: 38;"></div>' % a
IPW = ipad_sidebar(FULL_ROWS, 'Plan') + workspace(964, 796, ['Tue', 'Wed', 'Thu'], False)
ANW = android_drawer(FULL_ROWS, 'Plan') + workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True)
SF = '-apple-system, system-ui, sans-serif'; RB = 'Roboto, system-ui, sans-serif'
# iPadOS 26 menu bar, shown while ⌘ is held (menus as on the Mac app: app_menu.dart)
menus = ['Dottoday', 'File', 'Edit', 'View', 'Go', 'Window']
bar = ('<div role="menubar" aria-label="Menu bar" style="position: absolute; left: 0; right: 0; top: 0; height: 32px; z-index: 41; display: flex; align-items: center; gap: 4px; padding: 0 16px; '
       'background: rgba(250,247,242,.92); backdrop-filter: blur(30px); box-shadow: 0 .5px 0 rgba(36,31,43,.16); font: 600 14px %s; color: %s;">%s</div>') % (
           SF, INK, ''.join('<span role="menuitem" style="padding: 4px 10px; border-radius: 8px; %s">%s</span>' % (('background: %s; color: #fff;' % ACC) if m == 'View' else ('font-weight: 800;' if m == 'Dottoday' else ''), m) for m in menus))
go = [('Today', '⌘1'), ('Inbox', '⌘2'), ('Week', '⌘3'), ('Month', '⌘4'), None, ('Keyboard Shortcuts', '⌘/')]
gm = ''.join('<div style="height: 1px; margin: 4px 10px; background: rgba(36,31,43,.10);"></div>' if g is None else
             '<div role="menuitem" style="height: 36px; display: flex; align-items: center; justify-content: space-between; padding: 0 14px; font: 500 15px %s;"><span>%s</span><span style="color: %s;">%s</span></div>' % (SF, g[0], SEC, g[1]) for g in go)
gomenu = ('<div role="menu" aria-label="View" style="position: absolute; left: 196px; top: 36px; width: 250px; padding: 6px 0; border-radius: 14px; z-index: 42; background: rgba(250,247,242,.94); backdrop-filter: blur(30px); '
          'box-shadow: inset 0 0 0 1px rgba(255,255,255,.6), 0 0 0 .5px rgba(36,31,43,.14), 0 18px 48px rgba(36,31,43,.22); color: %s;">%s</div>') % (INK, gm)
F = {}
F['i1'] = device(1180, 820, IPW.replace('top: 24px;', 'top: 32px;', 0) + bar + gomenu, False)
F['i2'] = device(1180, 820, IPW + scrim() + '<div style="position: absolute; left: 130px; top: 70px; z-index: 40;">%s</div>' % sheet(True, 920, 700, SF), False)
# Android Keyboard Shortcuts Helper (Meta+/): system panel, "Current app" lists the app's shortcuts once registered natively
tabs = ['System', 'Multitasking', 'Input', 'Open apps', 'Current app']
helper_rows = ''.join('<div style="display: flex; align-items: center; justify-content: space-between; min-height: 44px; padding: 0 16px; border-radius: 12px; background: %s; margin-bottom: 4px;"><span style="font: 400 15px %s;">%s</span><span>%s</span></div>' % (
    SURF, RB, a, kbd(k, RB)) for k, a in groups(False)[0][1][:7])
helper = ('<div role="dialog" aria-label="Keyboard shortcuts, system" style="position: absolute; left: 140px; right: 140px; bottom: 0; height: 620px; z-index: 40; border-radius: 28px 28px 0 0; background: #F3EEE6; padding: 12px 24px; box-sizing: border-box; font-family: %s; color: %s;">'
          '<div aria-hidden="true" style="width: 32px; height: 4px; border-radius: 2px; background: #79747E; margin: 0 auto 14px;"></div>'
          '<div style="display: flex; align-items: center; gap: 12px;"><span style="font: 400 24px %s;">Keyboard shortcuts</span><span style="margin-left: auto; height: 44px; width: 300px; border-radius: 22px; background: #ECE5DC; display: flex; align-items: center; padding: 0 16px; font: 400 15px %s; color: %s;">Search shortcuts</span></div>'
          '<div style="display: flex; gap: 16px; margin-top: 16px;"><div style="width: 200px; display: flex; flex-direction: column; gap: 4px;">%s</div>'
          '<div style="flex: 1;"><div style="font: 500 14px %s; color: %s; margin: 6px 0 8px;">Dottoday · Everywhere</div>%s<div style="font: 500 13px %s; color: %s; margin-top: 8px;">Today, Week and Month, Inbox and Editing a task follow (scroll).</div></div></div></div>') % (
              RB, INK, RB, RB, SEC, ''.join('<div style="height: 48px; display: flex; align-items: center; padding: 0 16px; border-radius: 24px; font: 500 15px %s; %s">%s</div>' % (RB, 'background: #CFE8E4; color: #062F2C;' if t == 'Current app' else '', t) for t in tabs),
              RB, SEC, helper_rows, RB, SEC)
F['a1'] = device(1280, 800, ANW + scrim() + helper, True)
F['a2'] = device(1280, 800, ANW + scrim() + '<div style="position: absolute; left: 160px; top: 60px; z-index: 40;">%s</div>' % sheet(False, 960, 690, RB).replace('border-radius: 26px;', 'border-radius: 28px;', 1), True)

def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
ri = [fr('i1', 1180, 820, .55, '1 · Hold ⌘ → the iPadOS menu bar', 'On iPadOS 26, holding ⌘ with a hardware keyboard shows the system menu bar. Its menus are the Mac app’s, as built in <code>app_menu.dart</code>: File, Edit, View, Go, Window; View shown open with ⌘1–4 and Keyboard Shortcuts ⌘/. Drawn by the system, not the app. <b>Verify on device</b> (ED-095).'),
      fr('i2', 1180, 820, '.55'.strip() and .55, '2 · ⌘/ → Keyboard shortcuts', 'The built sheet (M3e.6) in E: the five built groups, two columns, every row with its keys. A form sheet over the dimmed Workspace; Esc or ✕ closes.')]
ra = [fr('a1', 1280, 800, .5, '1 · Meta+/ → Android’s Keyboard Shortcuts Helper', 'The system panel; its “Current app” tab lists Dottoday’s shortcuts once they are registered natively (the Flutter app does not do this yet). Drawn as the system shows it, not restyled. <b>Needs native registration; verify on device.</b>'),
      fr('a2', 1280, 800, .5, '2 · Ctrl+/ → Keyboard shortcuts', 'The same built sheet with Ctrl keys, as an M3 dialog.')]
notes = ['<b>Two lists, by design:</b> the system one (iPad menu bar on ⌘-hold; Android Meta+/) for people who expect the platform, and the app’s own built sheet (⌘/ or Ctrl+/) as the one complete list everywhere, including Mac, web and phones with a keyboard.',
         '<b>One scheme (ED-095, ED-248):</b> ⌘ on iPad and Mac, Ctrl on Android and web on other hosts. All keys and labels are the built ones (<code>app_shortcut_groups.dart</code>); nothing new.',
         '<b>Touch frames show no key hints</b> (R2-1); hints appear only in these lists and in menus while a keyboard is attached.',
         '<b>Open (implementation, ED-095):</b> the iPad key commands and the Android shortcut registration need native code; both are unverified on devices. Drawing them does not make them built.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
def row(title, frs): return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>' % (title, title, ''.join(frs))
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-10 · Keyboard overlays on tablets</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 2, last board. The checklist asked to draw the overlays’ contents (ED-095, ED-248). Dark on E-R2-10-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s%s') % (
            tag('th', 'Proposed · for owner review'), tag('tn', 'Light'), li, row('iPad with a keyboard', ri), row('Android tablet with a keyboard', ra))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-10</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1500px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1500,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-10.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-10</title>', '<title>E · R2-10 · Dark</title>').replace('Dark on E-R2-10-Dark.', 'Light on E-R2-10.').replace('>Light</span>', '>Dark</span>').replace('background: rgba(250,247,242,', 'background: rgba(43,38,42,')
open('project/E-R2-10-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
