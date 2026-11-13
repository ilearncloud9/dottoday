import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP1 = open(L + 'E-Phones.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
IPH, AND = frame_at(EP1, 5323), frame_at(EP1, 87361)
SEL = ('Team standup', 'Deep work: roadmap', 'Call with Sam')
CHECK = '<svg class="i" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true" style="stroke-width: 3; color: #fff;"><path d="M5 12.5l4.5 4.5L19 7.5"></path></svg>'
def ring(on): return ('<span style="width: 28px; height: 28px; border-radius: 50%%; display: flex; align-items: center; justify-content: center; %s">%s</span>'
                      % (('background: %s;' % ACC) if on else 'box-shadow: inset 0 0 0 2px #8A8494;', CHECK if on else ''))
def selecting(fr):
    """Select mode on a phone Today (built behaviour, docs/03 §3.2): every row ends in a ring; picked rows show a filled check and a light tint."""
    def rep(m):
        name = m.group(1); on = name in SEL
        return ('<button aria-label="%s, %s" aria-pressed="%s" style="%s">%s</button>' % (name, 'selected' if on else 'not selected', 'true' if on else 'false', m.group(2), ring(on)))
    fr = re.sub(r'<button aria-label="Mark ([^"]+) done" style="([^"]*)">.*?</button>', rep, fr, flags=re.S)
    fr = re.sub(r'<button aria-label="([^"]+), done\. Reopen" style="([^"]*)">.*?</button>', rep, fr, flags=re.S)
    for n in SEL:
        i = fr.find('aria-label="%s, selected"' % n)
        if i < 0: continue
        a = fr.rfind('role="listitem" style="', 0, i)
        if a > 0:
            a += len('role="listitem" style="'); fr = fr[:a] + 'background: rgba(17,97,92,.07); border-radius: 16px; ' + fr[a:]
    for tip in ('Hold a dot to select several tasks', 'Long-press a dot to select several'):
        i = fr.find(tip)
        if i > 0:
            a = fr.rfind('<div', 0, i); fr = fr[:a] + fr[block(fr, a, 'div'):]
    return fr

IC = {'move': '<path d="M5 12h14M13 6l6 6-6 6"></path>', 'dup': '<rect x="8" y="8" width="11" height="11" rx="2.5"></rect><path d="M5 15V7a2 2 0 0 1 2-2h8"></path>',
      'colour': '<circle cx="12" cy="12" r="8"></circle><path d="M12 4a8 8 0 0 0 0 16z" fill="currentColor"></path>', 'routine': '<path d="M4 10V9a3 3 0 0 1 3-3h12l-3-3M20 14v1a3 3 0 0 1-3 3H5l3 3"></path>',
      'trash': '<path d="M4 7h16M9 7V5h6v2M7 7l1 13h8l1-13"></path>', 'x': '<path d="M6 6l12 12M18 6L6 18"></path>', 'more': '<circle cx="12" cy="5" r="1.4" fill="currentColor"></circle><circle cx="12" cy="12" r="1.4" fill="currentColor"></circle><circle cx="12" cy="19" r="1.4" fill="currentColor"></circle>'}
def svg(k, s=22): return '<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true">%s</svg>' % (s, s, IC[k])
ACTS = [('Move', 'move'), ('Duplicate', 'dup'), ('Colour', 'colour'), ('Save as routine', 'routine'), ('Delete', 'trash')]
def act_btn(t, k, font, w=None):
    return ('<button style="flex: 1; %s min-height: 52px; border: 0; background: transparent; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; '
            'font: 600 12px %s; color: %s;">%s<span style="white-space: nowrap;">%s</span></button>') % ('width: %dpx; flex: none;' % w if w else '', font, INK, svg(k), t)
def card_bar(width, font):
    """Option A: the built floating card (SelectionBarFrame), in E's surface."""
    return ('<div role="toolbar" aria-label="3 selected" style="width: %dpx; box-sizing: border-box; padding: 6px; border-radius: 26px; background: %s; '
            'box-shadow: 0 0 0 1px rgba(36,31,43,.08), 0 12px 32px rgba(36,31,43,.18);">'
            '<div style="display: flex; align-items: center; height: 44px;"><button aria-label="Done selecting" style="width: 44px; height: 44px; border: 0; background: transparent; color: %s; display: flex; align-items: center; justify-content: center;">%s</button>'
            '<span aria-live="polite" style="font: 700 17px Manrope; color: %s;">3 selected</span></div>'
            '<div style="display: flex;">%s</div></div>') % (width, SURF, INK, svg('x'), INK, ''.join(act_btn(t, k, font) for t, k in ACTS))

# --- phones
def hide(fr, pat):
    i = fr.find(pat)
    if i < 0: return fr
    a = fr.rfind('<', 0, i); tag = re.match(r'<(\w+)', fr[a:]).group(1); return fr[:a] + fr[block(fr, a, tag):]
def phone_A(fr, android):
    w = 390 if not android else 412
    bottom = 104 if not android else 112
    return fr[:-6] + ('<div style="position: absolute; left: 10px; right: 10px; bottom: %dpx; z-index: 40;">%s</div>' % (bottom, card_bar(w - 20, 'Roboto, system-ui, sans-serif' if android else "-apple-system, 'SF Pro Text', system-ui, sans-serif"))) + '</div>'
def phone_B_ios(fr):
    fr = hide(fr, 'aria-label="Main"')
    for pat in ('aria-label="Add a task. Hold for Brain dump, Routine, Paste a list"', 'aria-label="Day menu"'):
        fr = hide(fr, pat)
    tb = ('<div role="toolbar" aria-label="3 selected" style="position: absolute; left: 0; right: 0; bottom: 0; height: 92px; padding: 6px 8px 28px; box-sizing: border-box; display: flex; z-index: 40; '
          'background: rgba(250,247,242,.86); backdrop-filter: blur(30px); box-shadow: 0 -.5px 0 rgba(36,31,43,.16);">%s</div>') % ''.join(act_btn(t, k, "-apple-system, 'SF Pro Text', system-ui, sans-serif") for t, k in ACTS)
    top = ('<div style="position: absolute; left: 16px; right: 16px; top: 56px; height: 44px; display: flex; align-items: center; justify-content: space-between; z-index: 41; '
           'border-radius: 22px; background: rgba(250,247,242,.92); backdrop-filter: blur(30px); box-shadow: 0 0 0 .5px rgba(36,31,43,.14), 0 6px 16px rgba(36,31,43,.10); padding: 0 6px 0 16px;">'
           '<span aria-live="polite" style="font: 600 17px -apple-system, system-ui, sans-serif;">3 selected</span>'
           '<button aria-label="Done selecting" style="width: 36px; height: 36px; border: 0; border-radius: 18px; background: rgba(36,31,43,.06); color: %s; display: flex; align-items: center; justify-content: center;">%s</button></div>') % (INK, svg('x', 18))
    return fr[:-6] + tb + top + '</div>'
def phone_B_and(fr):
    fr = hide(fr, 'aria-label="Main"')
    for pat in ('aria-label="Add a task. Hold for Brain dump, Routine, Paste a list"', 'aria-label="Day menu"'):
        fr = hide(fr, pat)
    bar = ('<div role="toolbar" aria-label="3 selected" style="position: absolute; left: 0; right: 0; top: 28px; height: 64px; display: flex; align-items: center; gap: 4px; padding: 0 8px 0 4px; z-index: 41; background: #CFE8E4; color: #062F2C;">'
           '<button aria-label="Done selecting" style="width: 48px; height: 48px; border: 0; background: transparent; color: #062F2C; display: flex; align-items: center; justify-content: center;">%s</button>'
           '<span aria-live="polite" style="flex: 1; font: 400 22px Roboto, system-ui, sans-serif;">3 selected</span>%s'
           '<button aria-label="More: Save as routine, Delete" style="width: 48px; height: 48px; border: 0; background: transparent; color: #062F2C; display: flex; align-items: center; justify-content: center;">%s</button></div>') % (
               svg('x'), ''.join('<button aria-label="%s" style="width: 48px; height: 48px; border: 0; background: transparent; color: #062F2C; display: flex; align-items: center; justify-content: center;">%s</button>' % (t, svg(k)) for t, k in ACTS[:3]), svg('more'))
    return fr[:-6] + bar + '</div>'

# --- tablets: selected blocks on the grid
def tab_sel(h):
    for n, lab in (('Lunch', 'Lunch, 12:30 to 1:15'), ('Pick up parcel', None)):
        pass
    n = {'c': 0}
    def pick(m):
        if m.group(2) == 'Lunch, 12:30 to 1:15':
            n['c'] += 1
            if n['c'] > 2: return m.group(0)
        return m.group(1) + m.group(3) + ' box-shadow: 0 0 0 2.5px %s; z-index: 3;' % ACC + m.group(4) + '<span aria-hidden="true" style="position: absolute; right: 8px; top: 8px; width: 24px; height: 24px; border-radius: 50%%; background: %s; display: flex; align-items: center; justify-content: center;">%s</span>' % (ACC, CHECK)
    h = re.sub(r'(<button class="blk" aria-label="(Lunch, 12:30 to 1:15|Dentist, 2:00 to 2:30)")( style="[^"]*?)(">)', pick, h)
    if False: h = re.sub(r'(<button class="blk" aria-label="(?:Lunch, 12:30 to 1:15|Dentist, 2:00 to 2:30)[^"]*")( style="[^"]*?)(">)',
               lambda m: m.group(1) + m.group(2) + ' box-shadow: 0 0 0 2.5px %s; z-index: 3;' % ACC + m.group(3) +
               '<span aria-hidden="true" style="position: absolute; right: 8px; top: 8px; width: 24px; height: 24px; border-radius: 50%%; background: %s; display: flex; align-items: center; justify-content: center;">%s</span>' % (ACC, CHECK), h)
    return h.replace(', now, 18 minutes left, selected', '').replace(' box-shadow: 0 0 0 2.5px #11615C; z-index: 2;', '')
def ws_ip(): return tab_sel(workspace(964, 796, ['Tue', 'Wed', 'Thu'], False))
def ws_an(): return tab_sel(workspace(1064, 772, ['Mon', 'Tue', 'Wed', 'Thu'], True))
def tab_A(android):
    w, h = (1280, 800) if android else (1180, 820)
    body = (android_drawer(FULL_ROWS, 'Plan') + ws_an()) if android else (ipad_sidebar(FULL_ROWS, 'Plan') + ws_ip())
    card = '<div style="position: absolute; left: %dpx; bottom: 28px; z-index: 40;">%s</div>' % (216 + 240 + ((w - 216 - 240) - 470) // 2, card_bar(470, 'Roboto, system-ui, sans-serif' if android else '-apple-system, system-ui, sans-serif'))
    return device(w, h, body + card, android)
def tab_B(android):
    w, h = (1280, 800) if android else (1180, 820)
    body = (android_drawer(FULL_ROWS, 'Plan') + ws_an()) if android else (ipad_sidebar(FULL_ROWS, 'Plan') + ws_ip())
    top = 28 if android else 24
    f = 'Roboto, system-ui, sans-serif' if android else '-apple-system, system-ui, sans-serif'
    acts = ''.join('<button style="height: 44px; padding: 0 14px; border: 0; border-radius: 22px; background: %s; display: flex; align-items: center; gap: 8px; font: 600 15px %s; color: %s;">%s%s</button>' % (
        '#ECE5DC' if not android else 'transparent', f, INK if not android else '#062F2C', svg(k, 20), t) for t, k in ACTS)
    bar = ('<div role="toolbar" aria-label="3 selected" style="position: absolute; left: 216px; right: 0; top: %dpx; height: 60px; display: flex; align-items: center; gap: 8px; padding: 0 14px; z-index: 41; background: %s; box-shadow: 0 1px 0 rgba(36,31,43,.08);">'
           '<button aria-label="Done selecting" style="width: 44px; height: 44px; border: 0; border-radius: 22px; background: %s; color: %s; display: flex; align-items: center; justify-content: center;">%s</button>'
           '<span aria-live="polite" style="font: %s; margin-right: auto; color: %s;">3 selected</span>%s</div>') % (
               top, '#CFE8E4' if android else '#F6F1EA', 'transparent' if android else '#ECE5DC', '#062F2C' if android else INK, svg('x', 20),
               '400 22px Roboto, system-ui, sans-serif' if android else '700 17px -apple-system, system-ui, sans-serif', '#062F2C' if android else INK, acts)
    return device(w, h, body + bar, android)

F = {'iA': selecting(phone_A(IPH, False)), 'aA': selecting(phone_A(AND, True)), 'iB': selecting(phone_B_ios(IPH)), 'aB': selecting(phone_B_and(AND)),
     'tiA': tab_A(False), 'taA': tab_A(True), 'tiB': tab_B(False), 'taB': tab_B(True)}
def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px;"><figcaption style="font: 700 14px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div></figure>') % (label, w * sc + 18, h * sc + 18, w, h, sc, F[key])
def opt(title, tags, notes, keys):
    li = ''.join('<li style="margin: 0 0 6px;">%s</li>' % n for n in notes)
    return ('<section aria-label="%s" style="display: flex; gap: 28px; align-items: flex-start;"><div style="width: 380px; flex: none; display: flex; flex-direction: column; gap: 10px;">'
            '<div style="font: 700 22px Manrope;">%s</div><div style="display: flex; flex-wrap: wrap; gap: 6px;">%s</div><ul style="margin: 4px 0 0; padding-left: 18px; font-size: 14px; line-height: 21px; color: #4E4757;">%s</ul></div>'
            '<div style="display: flex; gap: 22px; align-items: flex-start;">%s%s%s%s</div></section>') % (title, title, tags, li,
                fr(keys[0], 390, 844, .62, 'iPhone'), fr(keys[1], 412, 892, .6, 'Android phone'), fr(keys[2], 1180, 820, .4, 'iPad · Workspace'), fr(keys[3], 1280, 800, .4, 'Android tablet · Workspace'))
rows = [opt('A · The built card, in E, everywhere (recommended)', tag('td', 'Built today · SelectionBarFrame') + tag('tn', 'Navigation stays'), [
             'The app’s own selection card: “3 selected” with ✕ (Done selecting), then Move · Duplicate · Colour · Save as routine · Delete, icon over label. Restyled in E’s surface, floating above the bottom row (phones) or centred under the grid (tablets, Mac, web).',
             'Tabs, + and Day stay visible; the count is a live region; Esc closes (built).',
             'One design for every platform; nothing to rebuild beyond the look.'], ['iA', 'aA', 'tiA', 'taA']),
        opt('B · Platform-native selection mode', tag('tn', 'iOS edit toolbar · M3 contextual bar'), [
             'iPhone: the tab bar, + and Day give way to a bottom toolbar with the five actions; “3 selected” and ✕ float at the top (as Photos and Mail do).',
             'Android: the top app bar becomes the M3 contextual bar (✕, “3 selected”, Move, Duplicate, Colour, ⋮ for Save as routine and Delete); the floating toolbar hides.',
             'Tablets: the toolbar above the grid becomes the selection toolbar.',
             'More native, but the app’s built card becomes four platform presentations.'], ['iB', 'aB', 'tiB', 'taB'])]
notes = ['<b>Selecting (built, docs/03 §3.2, R-05):</b> hold a dot (iOS) or long-press (Android) to start; then tap rows to add or remove. Each row ends in a ring: empty, or filled with a check — never colour alone. Picked rows get a light teal tint. On the grid, a picked block gets the teal outline and a check badge.',
         '<b>Pointer and keyboard:</b> ⇧ / ⌘ / Ctrl-click adds to the selection (built); ↑↓ with Space picks rows; Esc ends selecting.',
         '<b>Copy</b> is the built strings only: “3 selected”, “Done selecting”, Move, Duplicate, Colour, Save as routine, Delete; Delete asks “Delete 3 tasks?” (built).',
         '<b>Switching Full ↔ Minimal clears a selection without applying anything (ED-100).</b> Mac and web follow the tablet frames with the pointer.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-6 · Multi-select and the selection bar (all platforms)</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 2, first board (ED-166). Multi-select is built in the app but drawn on no E board (CR-078), so this covers phones and tablets together. <b>Question R2-6a:</b> A or B. Phones from E-Phones; tablets on the approved touch Workspace. Dark on E-R2-6-Dark. For owner review.</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>') % (tag('th', 'Proposed · for owner review'), tag('th', 'Question R2-6a'), tag('tn', 'Light'), li)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-6</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 2440px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 36px;">\n' % H
        + body + '\n' + '\n'.join(rows) + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2440,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-6.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-6</title>', '<title>E · R2-6 · Dark</title>').replace('Dark on E-R2-6-Dark.', 'Light on E-R2-6.').replace('>Light</span>', '>Dark</span>').replace('background: rgba(250,247,242,', 'background: rgba(43,38,42,')
open('project/E-R2-6-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
