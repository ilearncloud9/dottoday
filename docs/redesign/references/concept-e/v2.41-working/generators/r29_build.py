import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
from frames import _ICON
IND = '#5B5FD6'
def sv(path, s=22, w=2): return '<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true" style="stroke-width: %s;">%s</svg>' % (s, s, w, path)
CHL, CHR, MORE = '<path d="M15 5l-7 7 7 7"></path>', '<path d="M9 5l7 7-7 7"></path>', '<circle cx="5" cy="12" r="1.5" fill="currentColor"></circle><circle cx="12" cy="12" r="1.5" fill="currentColor"></circle><circle cx="19" cy="12" r="1.5" fill="currentColor"></circle>'
BELL = '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4zM10 20a2 2 0 0 0 4 0"></path>'; MOON = '<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"></path>'
CHECK = '<path d="M5 12.5l4.5 4.5L19 7.5"></path>'
def switch(on, android):
    if android:
        return ('<span role="switch" aria-checked="%s" style="width: 52px; height: 32px; border-radius: 16px; flex: none; box-sizing: border-box; position: relative; %s"><span style="position: absolute; top: 50%%; %s border-radius: 50%%; transform: translateY(-50%%); %s"></span></span>') % (
            'true' if on else 'false', ('background: %s;' % ACC) if on else 'border: 2px solid #79747E;', 'right: 4px; width: 24px; height: 24px;' if on else 'left: 6px; width: 16px; height: 16px;', 'background: #FFFFFF;' if on else 'background: #79747E;')
    return ('<span role="switch" aria-checked="%s" style="width: 51px; height: 31px; border-radius: 16px; flex: none; position: relative; background: %s;"><span style="position: absolute; top: 2px; %s width: 27px; height: 27px; border-radius: 50%%; background: #FFFFFF; box-shadow: 0 2px 4px rgba(0,0,0,.18);"></span></span>') % (
        'true' if on else 'false', ACC if on else '#DDD7E0', 'right: 2px;' if on else 'left: 2px;')
def toggle(icon, label, on, android):
    return ('<div style="flex: 1; min-height: 64px; border-radius: 18px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06); display: flex; align-items: center; gap: 8px; padding: 8px 10px; box-sizing: border-box;">'
            '<span style="display: flex; color: #4E4757;">%s</span><span style="flex: 1; font: 600 14px/18px Manrope;">%s</span>%s</div>') % (SURF, sv(icon, 20), label, switch(on, android))
STEPS = [('Pull last quarter’s notes', 'done'), ('Draft three themes', 'done'), ('Size each theme', 'now'), ('Share with Sam', 'ahead')]
def step_row(t, st):
    mark = ('<span style="width: 24px; height: 24px; border-radius: 50%%; flex: none; display: flex; align-items: center; justify-content: center; %s">%s</span>' % (
        ('background: %s; color: #fff;' % ACC) if st == 'done' else ('box-shadow: inset 0 0 0 2px %s;' % (ACC if st == 'now' else '#8A8494')), sv(CHECK, 14, 3) if st == 'done' else ''))
    col = SEC + '; text-decoration: line-through' if st == 'done' else ('#0B4642; font-weight: 700' if st == 'now' else INK)
    return '<div role="listitem" style="display: flex; align-items: center; gap: 14px; min-height: 36px; font: 500 16px Manrope; color: %s;">%s<span>%s</span></div>' % (col, mark, t)
def focus_parts(width, android, ring=232):
    btn = 'height: 44px; border: 0; background: transparent; display: flex; align-items: center; justify-content: center;'
    top = ('<div style="display: flex; align-items: center; height: 52px;"><button style="%s gap: 2px; padding: 0 8px 0 0; color: #0B4642; font: 600 17px Manrope;">%sToday</button>'
           '<span role="heading" style="flex: 1; text-align: center; font: 700 13px Manrope; letter-spacing: 1.2px; color: %s;">FOCUS</span>'
           '<button aria-label="More" style="%s width: 44px; color: %s;">%s</button></div>') % (btn, sv(CHL, 22, 2.4), SEC, btn, INK, sv(MORE))
    ringh = ('<div style="display: flex; justify-content: center; margin-top: 18px;"><div role="img" aria-label="Deep work: roadmap, 85 percent of its time used" style="width: %dpx; height: %dpx; border-radius: 50%%; '
             'background: radial-gradient(closest-side, %s calc(100%% - 15px), transparent calc(100%% - 14.5px)), conic-gradient(%s 0 85%%, %s33 85%% 100%%); display: flex; align-items: center; justify-content: center; color: %s;">'
             '<svg class="i" width="64" height="64" viewBox="0 0 24 24" aria-hidden="true" style="stroke-width: 1.6;">%s</svg></div></div>') % (ring, ring, GROUND, IND, IND, IND, _ICON['Deep work: roadmap'])
    head = ('<div style="text-align: center; margin-top: 18px;"><div class="num" style="font: 500 16px Manrope; color: %s;">9:00 – 11:00 · 2 h</div>'
            '<div role="heading" style="font: 800 30px/36px Manrope; margin-top: 4px;">Deep work: roadmap</div><div class="num" style="font: 700 19px Manrope; color: #0B4642; margin-top: 4px;">18 min left</div></div>') % SEC
    card = ('<div style="margin-top: 22px; border-radius: 22px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06); padding: 16px 18px;">'
            '<div style="font: 700 12px Manrope; letter-spacing: 1px; color: %s;">STEP 3 OF 4</div><div style="font: 800 21px/27px Manrope; margin-top: 4px;">Size each theme</div>'
            '<div class="num" style="display: flex; gap: 10px; margin-top: 4px; font: 600 15px Manrope; color: %s;"><span style="color: #0B4642;">8:00 left</span><span>·</span><span>usually 20 min</span></div></div>') % (SURF, SEC, SEC)
    steps = '<div role="list" style="margin-top: 14px; display: flex; flex-direction: column; gap: 4px; padding: 0 4px;">%s</div>' % ''.join(step_row(*s) for s in STEPS)
    tg = '<div style="display: flex; gap: 10px; margin-top: 18px;">%s%s</div>' % (toggle(BELL, 'Chime every 15 min', False, android), toggle(MOON, 'Deep work · Focus on', True, android))
    done = ('<button style="margin-top: 20px; width: 100%%; height: 54px; border: 0; border-radius: 27px; background: %s; color: #fff; display: flex; align-items: center; justify-content: center; gap: 8px; font: 800 17px Manrope;">%sDone</button>') % (ACC, sv(CHECK, 20, 2.6))
    ob = 'flex: 1; height: 48px; border-radius: 24px; border: 0; background: transparent; box-shadow: inset 0 0 0 1.5px rgba(36,31,43,.22); font: 700 16px Manrope; color: %s; display: flex; align-items: center; justify-content: center; gap: 4px;' % INK
    row2 = '<div style="display: flex; gap: 10px; margin-top: 10px;"><button style="%s">+15 min</button><button style="%s">Next step%s</button></div>' % (ob, ob, sv(CHR, 18, 2.4))
    cap = '<div style="margin-top: 14px; text-align: center; font: 500 13px/18px Manrope; color: %s;">Dot starts still break through Focus (time-sensitive)</div>' % SEC
    return top, ringh + head, card + steps + tg + done + row2 + cap
def focus_view(width, android, ring=232):
    a, b, c = focus_parts(width, android, ring)
    return '<div role="main" aria-label="Focus" style="width: %dpx; font-family: Manrope, system-ui, sans-serif; color: %s;">%s%s%s</div>' % (width, INK, a, b, c)

def phone(android, inner):
    if android:
        sh = ('<div style="position: relative; width: 412px; height: 892px; border-radius: 44px; background: %s; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 8px #241F2B, 0 0 0 9px rgba(36,31,43,.35); font-family: Manrope, system-ui, sans-serif; color: %s;">'
              '<div aria-hidden="true" style="position: absolute; top: 12px; left: 198px; width: 16px; height: 16px; border-radius: 50%%; background: #000; z-index: 20;"></div>'
              '<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: 40px; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; font: 500 13px Roboto, system-ui; color: %s;"><span>10:42</span><span>▾ ▴ 100%%</span></div>'
              '<div style="position: absolute; left: 16px; top: 40px;">%s</div><div aria-hidden="true" style="position: absolute; left: 50%%; bottom: 8px; width: 108px; margin-left: -54px; height: 4px; border-radius: 2px; background: %s;"></div></div>') % (GROUND, INK, INK, inner, INK)
        return sh
    return ('<div style="position: relative; width: 390px; height: 844px; border-radius: 55px; background: %s; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 9px #241F2B, 0 0 0 10px rgba(36,31,43,.35); font-family: Manrope, system-ui, sans-serif; color: %s;">'
            '<div aria-hidden="true" style="position: absolute; top: 11px; left: 132px; width: 126px; height: 37px; border-radius: 25px; background: #000; z-index: 20;"></div>'
            '<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: 54px; display: flex; align-items: center; justify-content: space-between; padding: 0 34px; font: 600 16px -apple-system, system-ui; color: %s;"><span>10:42</span><span>100 %%</span></div>'
            '<div style="position: absolute; left: 16px; top: 54px;">%s</div><div aria-hidden="true" style="position: absolute; bottom: 8px; left: 128px; width: 134px; height: 5px; border-radius: 3px; background: %s;"></div></div>') % (GROUND, INK, INK, inner, INK)

F = {}
F['ip'] = phone(False, focus_view(358, False, 200))
F['an'] = phone(True, focus_view(380, True, 210))
def tab_A(android):
    w, h, top = (1280, 800, 28) if android else (1180, 820, 24)
    nav = android_drawer(FULL_ROWS, 'Plan') if android else ipad_sidebar(FULL_ROWS, 'Plan')
    cw = w - 216
    col = 'position: absolute; left: %dpx; top: %dpx; width: %dpx;' % (216 + (cw - 560) // 2, top + 4, 560)
    body = '<div style="position: absolute; left: 216px; right: 0; top: %dpx; bottom: 0; background: %s;"></div><div style="%s">%s</div>' % (top, GROUND, col, focus_view(560, android, 168).replace('margin-top: 22px;', 'margin-top: 14px;').replace('margin-top: 18px;', 'margin-top: 10px;'))
    return device(w, h, nav + body, android)
def tab_B(android):
    w, h, top = (1280, 800, 28) if android else (1180, 820, 24)
    # whole window: two columns (ring and title | steps, toggles, actions)
    topbar, ringhead, rest = focus_parts(1000, android, 232)
    body = ('<div style="position: absolute; left: 0; right: 0; top: %dpx; padding: 0 32px; font-family: Manrope; color: %s;">%s</div>'
            '<div style="position: absolute; left: 60px; top: %dpx; width: %dpx;">%s</div>'
            '<div style="position: absolute; right: 60px; top: %dpx; width: 460px; font-family: Manrope; color: %s;">%s</div>') % (top + 4, INK, topbar, top + 70, w // 2 - 80, ringhead, top + 96, INK, rest.replace('margin-top: 22px;', 'margin-top: 0;', 1))
    return device(w, h, body, android)
F['tA_i'], F['tA_a'], F['tB_i'], F['tB_a'] = tab_A(False), tab_A(True), tab_B(False), tab_B(True)

def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px;"><figcaption style="font: 700 14px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div></figure>') % (label, w * sc + 18, h * sc + 18, w, h, sc, F[key])
phones = '<section aria-label="Phones" style="display: flex; gap: 28px; align-items: flex-start;"><div style="width: 380px; flex: none;"><div style="font: 700 22px Manrope;">Phones and compact windows</div><ul style="margin: 10px 0 0; padding-left: 18px; font-size: 14px; line-height: 21px; color: #4E4757;"><li style="margin-bottom: 6px;">Full screen (<code>/focus/:id</code>, built). ‹ Today leaves; Back / Esc too.</li><li style="margin-bottom: 6px;">The ring is E’s current-task ring at Focus size, with the task’s icon; then the time, title and “18 min left”.</li><li>Step card, the step thread, the two built toggles, Done, +15 min and Next step, and the break-through note. Scrolls at large text.</li></ul></div>%s%s</section>' % (fr('ip', 390, 844, .72, 'iPhone'), fr('an', 412, 892, .7, 'Android phone'))
def opt(title, tags, notes, a, b):
    li = ''.join('<li style="margin: 0 0 6px;">%s</li>' % n for n in notes)
    return ('<section aria-label="%s" style="display: flex; gap: 28px; align-items: flex-start;"><div style="width: 380px; flex: none; display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; flex-wrap: wrap; gap: 6px;">%s</div>'
            '<ul style="margin: 4px 0 0; padding-left: 18px; font-size: 14px; line-height: 21px; color: #4E4757;">%s</ul></div>%s%s</section>') % (title, title, tags, li, a, b)
rows = [phones,
        opt('A · Focus replaces the content; the sidebar stays (recommended)', tag('td', 'Built today · FocusFrame'), [
            'Expanded tablets, Mac and web: Focus takes the content area, centred in one readable column; the sidebar (or drawer) stays, so Today, Inbox and Settings are one tap away.',
            'The tabs underneath keep their state; Esc or ‹ Today returns (built).',
            'Medium windows use the phone screen. The column scrolls: +15 min, Next step and the note sit below Done.'], fr('tA_i', 1180, 820, .48, 'iPad · 1180 × 820'), fr('tA_a', 1280, 800, .48, 'Android tablet · 1280 × 800')),
        opt('B · Focus takes the whole window', tag('tn', 'More immersive · new layout'), [
            'The sidebar hides; the ring and title on the left, the step and actions on the right.',
            'Fewer distractions, but a second Focus layout to build and test, and leaving means one more step back to the places.'], fr('tB_i', 1180, 820, .48, 'iPad · 1180 × 820'), fr('tB_a', 1280, 800, .48, 'Android tablet · 1280 × 800'))]
notes = ['<b>Built, never drawn (CR-076):</b> the Focus screen exists (<code>features/focus/</code>) with every part shown here; this board draws it in E for the first time, on every platform. Entry points stay as approved: the Focus tile in the editor, Focus on E-Minimal’s Now, ⌘F / Ctrl+F.',
         '<b>Copy is built strings only:</b> “Today”, “FOCUS”, “18 min left”, “Step 3 of 4”, “8:00 left”, “usually 20 min”, “Chime every 15 min”, “Deep work · Focus on”, “Done”, “+15 min”, “Next step”, and the break-through note.',
         '<b>Deep work · Focus on</b> asks for Do Not Disturb access on Android; on iPhone and Mac it explains the Shortcuts route; on web it says to use the computer’s own setting (built). Apple Pencil: nothing proposed.',
         '<b>Accessibility:</b> built: the toggles stack above 130 % text, Esc leaves, the title is a heading, no sound unless Chime is on. Design rules to check in the build: the ring is one image with a spoken label; Reduced Motion stops its animation.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-9 · Focus (all platforms)</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 2, fourth board. <b>Question R2-9a:</b> on expanded windows, A or B. Sample: Deep work: roadmap, step 3 of 4. Dark on E-R2-9-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s') % (
            tag('th', 'Proposed · for owner review'), tag('th', 'Question R2-9a'), tag('tn', 'Light'), li, '\n'.join(rows))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-9</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1800px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 36px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1800,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-9.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-9</title>', '<title>E · R2-9 · Dark</title>').replace('Dark on E-R2-9-Dark.', 'Light on E-R2-9.').replace('>Light</span>', '>Dark</span>')
open('project/E-R2-9-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
