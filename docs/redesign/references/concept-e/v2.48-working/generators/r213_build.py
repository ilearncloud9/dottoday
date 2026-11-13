import os, sys, re
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r22')
H = int(sys.argv[1])
import ws
from ws import *
from frames import _ICON
L = '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/live/project/'
EP1 = open(L + 'E-Phones.dc.html', encoding='utf-8').read()
def frame_at(s, st): return s[st:block(s, st, 'div')]
IPH, AND = frame_at(EP1, 5323), frame_at(EP1, 87361)
def grab(fr, marker, tag):
    i = fr.index(marker); a = fr.rfind('<' + tag, 0, i); return fr[a:block(fr, a, tag)]
# the approved bottom bars, with Inbox or Search selected
def bar(fr, sel, android):
    b = grab(fr, 'aria-label="Main"', 'nav')
    return b
SF, RB = "-apple-system, 'SF Pro Text', system-ui, sans-serif", 'Roboto, system-ui, sans-serif'
def sv(p, s=20, w=2): return '<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true" style="stroke-width: %s;">%s</svg>' % (s, s, w, p)
SEARCH = '<circle cx="11" cy="11" r="6.5"></circle><path d="M20 20l-4.2-4.2"></path>'; PLUS = '<path d="M12 5v14M5 12h14"></path>'; CHEV = '<path d="M9 5l7 7-7 7"></path>'
def chip(t, on=False):
    return '<span role="radio" aria-checked="%s" style="height: 36px; padding: 0 14px; border-radius: 18px; display: inline-flex; align-items: center; font: 600 14px Manrope; white-space: nowrap; %s">%s</span>' % (
        'true' if on else 'false', ('background: %s; color: #0B4642; box-shadow: inset 0 0 0 1.5px %s;' % ('#E2EFEC', ACC)) if on else ('background: %s; color: %s; box-shadow: inset 0 0 0 1px rgba(36,31,43,.14);' % (SURF, INK)), t)
INBOX = [('Buy a birthday gift', '30 min · added today', 'Fits today 11:00', '#D9668F', 'Gym'), ('Book the car service', '30 min · added yesterday', 'Fits today 4:00', '#4A9BD6', 'Pick up parcel'),
         ('Call Mum tomorrow 3pm', '20 min · added today', 'Fits Wed 3:00', '#2A9D8F', 'Call with Sam')]
def ring(col, d=36): return '<span aria-hidden="true" style="width: %dpx; height: %dpx; border-radius: 50%%; flex: none; box-shadow: inset 0 0 0 3px %s;"></span>' % (d, d, col)
def inbox_row(t, meta, fit, col, ic, wide=False):
    return ('<div role="listitem" style="display: flex; align-items: center; gap: 12px; min-height: 64px; padding: 8px 10px 8px 12px; border-radius: 18px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">%s'
            '<div style="flex: 1; min-width: 0; line-height: 1.25;"><div style="font: 700 17px Manrope;">%s</div><div class="num" style="font: 500 13px Manrope; color: %s;">%s</div>'
            '<div class="num" style="font: 600 13px Manrope; color: #0B4642; margin-top: 2px;">%s</div></div>'
            '<button style="height: 44px; padding: 0 14px; border: 0; border-radius: 22px; background: #E2EFEC; color: #0B4642; font: 700 15px Manrope; flex: none;">%s</button></div>') % (
                SURF, ring(col), t, SEC, meta, fit, 'Place' if not wide else 'Place')
def inbox_col(w, font, title=True):
    rows = ''.join(inbox_row(*r) for r in INBOX)
    head = ('<div role="heading" style="font: 800 32px/38px Manrope;">Inbox</div><div class="num" style="font: 600 15px Manrope; color: %s; margin-top: 2px;">3 unscheduled · 1 h 20 of work</div>' % SEC) if title else ''
    return ('<div style="width: %dpx; font-family: Manrope; color: %s;">%s'
            '<div role="textbox" aria-label="Add a task" style="margin-top: 14px; height: 48px; border-radius: 24px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.12); display: flex; align-items: center; gap: 8px; padding: 0 16px; font: 500 16px Manrope; color: %s; white-space: nowrap; overflow: hidden;">%s<span style="color: %s; font-weight: 600;"></span><span>Call Mum tomorrow 3pm 20m</span></div>'
            '<div style="display: flex; gap: 8px; margin-top: 12px; align-items: center;">%s%s<span style="margin-left: auto; font: 600 14px Manrope; color: %s;">Sort: added</span></div>'
            '<div class="num" style="margin-top: 12px; padding: 10px 14px; border-radius: 16px; background: #E2EFEC; font: 600 14px/19px Manrope; color: #0B4642;">Next free slot today: 11:00–11:45 AM · fits Buy a birthday gift</div>'
            '<div role="list" style="display: flex; flex-direction: column; gap: 8px; margin-top: 12px;">%s</div>'
            '<div style="display: flex; align-items: center; justify-content: space-between; margin-top: 14px; padding: 0 4px;"><span style="font: 700 15px Manrope; color: %s;">Completed · 2</span>%s</div>'
            '<button style="margin-top: 14px; width: 100%%; height: 48px; border: 0; border-radius: 24px; background: transparent; box-shadow: inset 0 0 0 1.5px rgba(36,31,43,.22); font: 700 16px Manrope; color: %s;">Auto-plan the week</button></div>') % (
                w, INK, head, SURF, SEC, sv(PLUS, 18, 2.4), INK, chip('All', True), chip('Fits today'), SEC, rows, SEC, sv(CHEV, 18), INK)
RESULTS = [('Tue · Today', [('Call with Sam', 'Today · 10:30–11:00 AM', '#2A9D8F', 'ahead'), ('Deep work: roadmap', 'Today · 9:00–11:00 AM', '#5B5FD6', 'now')]),
           ('Inbox', [('Send Sam the notes', 'Inbox · 15 min', '#8C6A4F', 'ahead')]),
           ('Earlier', [('Lunch with Sam', 'Mon 2 Nov · Done', '#D9668F', 'done')])]
def res_row(t, meta, col, st):
    d = ('<span aria-hidden="true" style="width: 36px; height: 36px; border-radius: 50%%; flex: none; background: %s;"></span>' % col) if st == 'done' else ring(col)
    mark = lambda s: s.replace('Sam', '<mark style="background: rgba(17,97,92,.18); color: inherit; border-radius: 4px; padding: 0 2px;">Sam</mark>')
    return ('<div role="listitem" style="display: flex; align-items: center; gap: 12px; min-height: 60px; padding: 6px 4px;">%s<div style="line-height: 1.25;"><div style="font: 700 17px Manrope; color: %s;">%s</div>'
            '<div class="num" style="font: 500 13px Manrope; color: %s;">%s</div></div></div>') % (d, SEC if st == 'done' else INK, mark(t), SEC, meta)
def search_col(w, font, query=True):
    field = ('<div role="search" style="height: 48px; border-radius: 24px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.12); display: flex; align-items: center; gap: 10px; padding: 0 16px; font: 500 17px Manrope; color: %s;">%s%s</div>') % (
        SURF, INK if query else SEC, sv(SEARCH, 20), 'Sam<span style="width: 2px; height: 22px; background: %s; margin-left: -8px;"></span>' % ACC if query else 'Search titles, notes and subtasks')
    chips = '<div style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 12px;">%s</div>' % ''.join(chip(c, c == 'All') for c in ('All', 'Today', 'This week', 'Inbox', 'Done', 'Colour', 'Icon'))
    if query:
        body = ''.join('<div role="heading" style="margin-top: 16px; font: 700 13px Manrope; letter-spacing: .6px; color: %s;">%s</div>%s' % (SEC, g.upper(), ''.join(res_row(*r) for r in rows)) for g, rows in RESULTS)
        body += '<div style="margin-top: 6px; font: 700 15px Manrope; color: #0B4642;">Show all</div>'
    else:
        rec = ''.join('<div style="display: flex; align-items: center; gap: 12px; height: 48px; font: 500 16px Manrope; border-top: 1px solid rgba(36,31,43,.06);"><span style="color: %s;">%s</span>%s</div>' % (SEC, sv(SEARCH, 18), q) for q in ('dentist', 'roadmap', 'Sam'))
        body = ('<div style="margin-top: 22px; font: 700 13px Manrope; letter-spacing: .6px; color: %s;">RECENT</div>%s<div style="margin-top: 22px; font: 500 15px/21px Manrope; color: %s;">Find anything you\'ve planned: titles, notes and subtasks, done ones too.</div>') % (SEC, rec, SEC)
    return ('<div style="width: %dpx; font-family: Manrope; color: %s;"><div role="heading" style="font: 800 32px/38px Manrope;">Search</div><div style="font: 600 15px Manrope; color: %s; margin: 2px 0 14px;">Everything you\'ve planned</div>%s%s%s</div>') % (w, INK, SEC, field, chips, body)

def phone(android, inner, sel):
    src = AND if android else IPH
    b = grab(src, 'aria-label="Main"', 'nav')
    # move the approved selected look from Today to the chosen tab
    anchors = list(re.finditer(r'<a href="#"( aria-current="page")?( aria-label="[^"]*")? style="([^"]*)"', b))
    def label(m): return re.sub(r'<[^>]+>', '|', b[m.end():b.index('</a>', m.end())]).strip('|').split('|')[0].strip() or re.sub(r'<[^>]+>', ' ', b[m.end():b.index('</a>', m.end())]).split()[0]
    names = [re.sub(r'<[^>]+>', ' ', b[m.end():b.index('</a>', m.end())]).split() for m in anchors]
    names = [[w for w in n if not w.isdigit()][-1] for n in names]
    sel_style = anchors[0].group(3); plain = anchors[2].group(3)
    out, last = [], 0
    for m, n in zip(anchors, names):
        st = sel_style if n == sel else (plain if m.group(1) else m.group(3))
        if n == sel and 'position: relative' in m.group(3) and 'position: relative' not in st: st = 'position: relative; ' + st
        out.append(b[last:m.start()] + '<a href="#"%s%s style="%s"' % (' aria-current="page"' if n == sel else '', m.group(2) or '', st)); last = m.end()
    b = ''.join(out) + b[last:]
    plus = grab(src, 'aria-label="Add a task', 'button')
    W, Hh, top = (412, 892, 40) if android else (390, 844, 54)
    shell = ('<div style="position: relative; width: %dpx; height: %dpx; border-radius: %dpx; background: %s; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 %dpx #241F2B, 0 0 0 %dpx rgba(36,31,43,.35); font-family: Manrope, system-ui, sans-serif; color: %s;">') % (
        W, Hh, 44 if android else 55, GROUND, 8 if android else 9, 9 if android else 10, INK)
    sb = ('<div aria-hidden="true" style="position: absolute; top: 12px; left: 198px; width: 16px; height: 16px; border-radius: 50%; background: #000; z-index: 20;"></div>' if android else
          '<div aria-hidden="true" style="position: absolute; top: 11px; left: 132px; width: 126px; height: 37px; border-radius: 25px; background: #000; z-index: 20;"></div>')
    st = '<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: %dpx; display: flex; align-items: center; justify-content: space-between; padding: 0 %dpx; font: 600 15px %s; color: %s;"><span>10:42</span><span>100 %%</span></div>' % (top, 24 if android else 34, RB if android else SF, INK)
    return shell + sb + st + '<div style="position: absolute; left: 16px; top: %dpx;">%s</div>' % (top + 10, inner) + b + plus + '</div>'
F = {}
F['ip_in'] = phone(False, inbox_col(358, SF), 'Inbox')
F['an_in'] = phone(True, inbox_col(380, RB), 'Inbox')
F['ip_se'] = phone(False, search_col(358, SF), 'Search')
F['an_se'] = phone(True, search_col(380, RB, query=False), 'Search')
# expanded: Inbox beside "Drop onto today" (built WideInbox); Search as one readable column
def today_panel(w):
    gaps = [('7:00', None), ('9:00', 'Deep work: roadmap'), ('10:30', 'Call with Sam'), ('11:00–11:45 · 45 min free', 'Buy a birthday gift'), ('12:30', 'Lunch'), ('2:00', 'Dentist'), ('3:00', 'Pick up parcel'), ('4:00–5:00 · 1 h free', 'Book the car service')]
    rows = []
    for t, n in gaps:
        if n is None: continue
        if 'free' in t:
            rows.append('<div style="margin: 4px 0 4px 18px; padding: 10px 14px; border-radius: 16px; border: 2px dashed rgba(17,97,92,.45); font: 600 14px/19px Manrope; color: #0B4642;">%s<br><span style="color: %s; font-weight: 500;">fits %s</span></div>' % (t, SEC, n))
        else:
            rows.append('<div style="display: flex; align-items: center; gap: 10px; height: 44px; font: 600 15px Manrope;"><span class="num" style="width: 44px; color: %s; font-size: 13px;">%s</span>%s</div>' % (SEC, t, n))
    return ('<aside aria-label="Drop onto today" style="width: %dpx; box-sizing: border-box; padding: 20px 22px; font-family: Manrope; color: %s;"><div role="heading" style="font: 800 22px Manrope;">Drop onto today</div>'
            '<div style="font: 500 14px Manrope; color: %s; margin: 2px 0 10px;">Drag a task onto a dotted gap, or press ⌘↩ on a row to place it in the first fitting slot.</div>%s</aside>') % (w, INK, SEC, ''.join(rows))
ipnav = ipad_sidebar(FULL_ROWS, 'Inbox'); annav = android_drawer(FULL_ROWS, 'Search')
F['ti'] = device(1180, 820, ipnav + '<div style="position: absolute; left: 216px; top: 24px; right: 0; bottom: 0; background: %s;"></div><div style="position: absolute; left: 248px; top: 44px;">%s</div>'
                 '<div style="position: absolute; left: 732px; top: 24px; right: 0; bottom: 0; background: #EFE7DB; box-shadow: -1px 0 0 rgba(36,31,43,.08);">%s</div>' % (GROUND, inbox_col(448, SF), today_panel(448)), False)
F['ta'] = device(1280, 800, annav + '<div style="position: absolute; left: 216px; top: 28px; right: 0; bottom: 0; background: %s;"></div><div style="position: absolute; left: %dpx; top: 48px;">%s</div>' % (GROUND, 216 + (1064 - 640) // 2, search_col(640, RB)), True)

def tag(c, t): return '<span class="%s">%s</span>' % (c, t)
def fr(key, w, h, sc, label, note=''):
    return ('<figure style="margin: 0; display: flex; flex-direction: column; gap: 8px; width: %dpx;"><figcaption style="font: 700 15px Manrope; color: #4E4757;">%s</figcaption>'
            '<div style="width: %dpx; height: %dpx;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>'
            '<div style="font-size: 13.5px; line-height: 20px; color: #4E4757;">%s</div></figure>') % (w * sc + 18, label, w * sc + 18, h * sc + 18, w, h, sc, F[key], note)
rin = [fr('ip_in', 390, 844, .62, 'iPhone · Inbox'), fr('an_in', 412, 892, .6, 'Android phone · Inbox'),
       fr('ti', 1180, 820, .5, 'iPad · expanded · Inbox beside Drop onto today', 'Built (WideInbox, M3e.2): the Inbox list and today’s thread side by side; each free gap names the first task that fits; drag a row onto a gap, or tap Place. Medium windows show the list alone.')]
rse = [fr('ip_se', 390, 844, .62, 'iPhone · Search, results'), fr('an_se', 412, 892, .6, 'Android phone · Search, empty with Recent'),
       fr('ta', 1280, 800, .5, 'Android tablet · expanded · Search', 'One readable column (640) in the content area; a result opens the task in the docked editor (R2-4). The drawer keeps Search selected.')]
notes = ['<b>Never drawn (CR-080):</b> Inbox and Search are built (<code>features/inbox</code>, <code>features/search</code>) and have tabs and sidebar rows, but no E board drew the screens. This board draws them in E for every platform at once.',
         '<b>Inbox (built content):</b> “3 unscheduled · 1 h 20 of work”; Add a task with the parser hint; All · Fits today; Sort; the next free slot; rows with their length, when added, where they fit and Place; Completed · 2; Auto-plan the week (a proposal, ED-150).',
         '<b>Search (built content):</b> “Search titles, notes and subtasks”; All · Today · This week · Inbox · Done · Colour · Icon; results grouped by day and Inbox with the match highlighted; Show all; Recent and the empty-state line.',
         '<b>Copy is built strings only;</b> no-shame rule kept (past tasks say “not done”, never “missed”). Bars are the approved iPhone tab bar and Android floating toolbar; tablets use R2-1 navigation.']
li = ''.join('<li style="margin: 0 0 8px;">%s</li>' % n for n in notes)
def row(title, frs): return '<section aria-label="%s" style="display: flex; flex-direction: column; gap: 12px;"><div style="font: 700 22px Manrope;">%s</div><div style="display: flex; gap: 28px; align-items: flex-start;">%s</div></section>' % (title, title, ''.join(frs))
body = ('<header style="display: flex; flex-direction: column; gap: 8px;"><h1 style="margin: 0; font-size: 34px; line-height: 40px; font-weight: 700; letter-spacing: -0.6px;">E · Round 2 · R2-13 · Inbox and Search (all platforms)</h1>'
        '<p style="margin: 0; font-size: 17px; line-height: 26px; color: #4E4757;">Stage 3, third board. Dark on E-R2-13-Dark. Approved by the owner, 13 Nov 2026 (ED-295).</p>'
        '<div style="display: flex; gap: 6px;">%s %s</div></header>'
        '<ul style="margin: 0; padding-left: 18px; font-size: 15px; line-height: 23px; color: #4E4757; columns: 2; column-gap: 48px;">%s</ul>%s%s') % (
            tag('tb', 'Approved · ED-295'), tag('tn', 'Light'), li, row('Inbox', rin), row('Search', rse))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-13</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1700px; height: %dpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 32px;">\n' % H
        + body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1700,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
os.makedirs('project', exist_ok=True)
open('project/E-R2-13.dc.html', 'w', encoding='utf-8').write(page)
sys.path.insert(0, 'h'); from darkify import darkify
dark = darkify(page).replace('class="blk-d', 'class="blk').replace('<title>E · R2-13</title>', '<title>E · R2-13 · Dark</title>').replace('Dark on E-R2-13-Dark.', 'Light on E-R2-13.').replace('<span class="tn">Light</span>', '<span class="tn">Dark</span>')
open('project/E-R2-13-Dark.dc.html', 'w', encoding='utf-8').write(dark)
print('ok')
