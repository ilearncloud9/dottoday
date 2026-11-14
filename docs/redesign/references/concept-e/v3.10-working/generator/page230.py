# R2-30 · Mac and web parity (gap pass): Search and Search or run, Routines, Focus, Trash, 3 days and Month, Minimal
# Inbox/Calendar/Search, the Edit and Window menus, Settings panes and Copy to which day. Built behaviour and strings,
# drawn inside the approved Mac and web shells (E-FullA-v2, E-Minimal). Settings icons from ED-332.
_p = open(os.path.join(HERE, '..', 'r229', 'page229.py'), encoding='utf-8').read()
exec(_p[:_p.rindex('# ---------------------------------------------------------------- page')].replace("os.path.join(HERE, '..', 'r228', 'page228.py')", "os.path.join(HERE, '..', 'r228', 'page228.py')"))
import json as _json
sys.path.insert(0, os.path.join(HERE, '..', 'iconaudit'))
import settings_icons as SI
ICONS = SI.canonical(os.path.join(HERE, '..', 'iconaudit', 'tiles.json'))
MF = "-apple-system, 'SF Pro Text', system-ui, sans-serif"
WF = 'Manrope, system-ui, sans-serif'
T = lambda name: open(os.path.join(HERE, name), encoding='utf-8').read()
MAC, WEB, MIN, MSET, MENUS = T('mac_full.html'), T('web_full.html'), T('macmin.html'), T('macset.html'), T('menus.html')


def stile(t, size=30, r=8, icon=18): return SI.tile(*ICONS[t], False, size, r, icon)


# ---------------------------------------------------------------- shells
def _select(nav, sel, bg, fw):
    def a(m):
        attrs, st, inner = m.group(1), m.group(2), m.group(3)
        attrs = re.sub(r' aria-current="[^"]*"', '', attrs)
        st = re.sub(r' ?background: [^;]+;', '', st).replace('color: #0B4642;', 'color: #241F2B;')
        st = re.sub(r' ?font-weight: \d+;', '', st)
        inner = re.sub(r'<span aria-hidden="true" style="width: 6px; height: 6px; border-radius: 50%; background: #11615C;"></span>', '', inner)
        label = re.sub(r'<[^>]+>', '', inner).strip()
        if label.startswith(sel) and (len(label) == len(sel) or not label[len(sel)].isalpha()):
            attrs += ' aria-current="page"'
            st = st.replace('color: #241F2B;', 'background: %s; color: #0B4642; font-weight: %s;' % (bg, fw), 1)
        return '<a href="#"%s style="%s">%s</a>' % (attrs, st, inner)
    return re.sub(r'<a href="#"((?: [\w-]+="[^"]*")*?) style="([^"]*)">(.*?)</a>', a, nav, flags=re.S)


def mac_win(sel, toolbar, body):
    i, j = MAC.index('<!-- sidebar'), MAC.index('<!-- main')
    nav = _select(MAC[i:j], sel, 'rgba(17,97,92,.14)', 600)
    main = ('<div style="position: absolute; left: 216px; top: 0; right: 0; bottom: 0; display: flex; flex-direction: column;">'
            '<div role="toolbar" style="height: 52px; flex: none; background: #F6F1EA; box-shadow: 0 1px 0 rgba(36,31,43,.08); display: flex; align-items: center; gap: 8px; padding: 0 14px; font: 13px %s;">%s</div>'
            '<div style="position: relative; flex: 1; overflow: hidden;">%s</div></div>') % (MF, toolbar, body)
    return MAC[:i] + nav + main + '</div>'


def web_win(sel, url, body):
    i, j = WEB.index('<!-- sidebar'), WEB.index('<!-- main')
    head = WEB[:i].replace('<span style="color: #6A6273;">/#/today?task=0193a1c2…</span>', '<span style="color: #6A6273;">%s</span>' % url, 1)
    nav = _select(WEB[i:j], sel, '#D9ECE9', 700)
    main = '<div style="position: absolute; left: 216px; top: 52px; right: 0; bottom: 0; overflow: hidden; font-family: %s;">%s</div>' % (WF, body)
    return head + nav + main + '</div>'


def min_win(sel, url, body):
    i, j = MIN.index('<!-- sidebar'), MIN.index('<!-- Now hero')
    head = MIN[:i].replace('<span style="color: #4E4757;">/#/now</span>', '<span style="color: #4E4757;">%s</span>' % url, 1).replace('Now · Dottoday', '%s · Dottoday' % sel, 1)
    nav = _select(MIN[i:j], sel, '#D9ECE9', 700)
    main = '<div style="position: absolute; left: 200px; top: 82px; right: 0; bottom: 0; overflow: hidden; font-family: %s;">%s</div>' % (WF, body)
    return head + nav + main + '</div>'


def btn(t, primary=False, f=WF): return '<span role="button" style="height: 34px; padding: 0 14px; border-radius: 17px; display: inline-flex; align-items: center; font: 600 13px %s; %s">%s</span>' % (
    f, 'background: #11615C; color: #fff;' if primary else 'background: #FFFDF9; color: #0B4642; box-shadow: 0 0 0 1px rgba(36,31,43,.12);', t)
def column(inner, w=640, top=28): return '<div style="width: %dpx; margin: %dpx auto 0; font-family: %s; color: #241F2B;">%s</div>' % (w, top, WF, inner)
def h1(t, sub=None, ring=None):
    r = ('<span class="num" style="margin-left: auto; height: 28px; padding: 0 12px; border-radius: 14px; background: #E2EFEC; color: #0B4642; display: flex; align-items: center; font: 700 13px %s;">%s</span>' % (WF, ring)) if ring else ''
    return ('<div style="display: flex; align-items: flex-end; gap: 12px;"><div><div style="font: 800 28px/34px %s;">%s</div>%s</div>%s</div>') % (
        WF, t, ('<div style="font: 500 14px %s; color: #4E4757; margin-top: 2px;">%s</div>' % (WF, sub)) if sub else '', r)
def card(inner, pad='4px 0'): return '<div style="border-radius: 18px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.07); padding: %s; overflow: hidden;">%s</div>' % (pad, inner)
def dot(c, done): return ('<span aria-hidden="true" style="width: 18px; height: 18px; border-radius: 50%%; flex: none; %s"></span>' % (('background: %s;' % c) if done else ('box-shadow: inset 0 0 0 3px %s;' % c)))
def trow(c, title, meta, done=False, end='', last=False):
    return ('<div style="min-height: 52px; display: flex; align-items: center; gap: 12px; padding: 6px 16px;%s">%s<span style="flex: 1;"><span style="display: block; font: 700 15px %s;%s">%s</span><span class="num" style="display: block; font: 500 12.5px %s; color: #6A6273;">%s</span></span>%s</div>') % (
        '' if last else ' box-shadow: inset 0 -1px 0 rgba(36,31,43,.06);', dot(c, done), WF, ' text-decoration: line-through; color: #6A6273;' if done else '', title, WF, meta, end)
def ghead(t, today=False): return '<div style="margin: 18px 4px 8px; font: 800 12px %s; letter-spacing: .8px; color: #4E4757;">%s</div>' % (WF, t.upper().replace('· TODAY', '· <span style="color: #11615C;">TODAY</span>') if today else t.upper())


# ---------------------------------------------------------------- 1 · Search and Search or run
CHIPS_S = ['All', 'Today', 'This week', 'Inbox', 'Done', 'Colour', 'Icon']
def schips(sel='All'):
    return '<div style="display: flex; gap: 8px; margin-top: 12px; flex-wrap: wrap;">%s</div>' % ''.join(
        '<span role="button" aria-pressed="%s" style="height: 32px; padding: 0 12px; border-radius: 16px; display: flex; align-items: center; gap: 4px; font: 600 13px %s; %s">%s%s</span>' % (
            'true' if c == sel else 'false', WF, 'background: #11615C; color: #fff;' if c == sel else 'background: #FFFDF9; color: #241F2B; box-shadow: 0 0 0 1px rgba(36,31,43,.12);', c,
            sv(DOWN_I, 12) if c in ('Colour', 'Icon') else '') for c in CHIPS_S)
def sfield(q):
    return ('<div role="searchbox" aria-label="Search titles, notes and subtasks" style="margin-top: 16px; height: 46px; border-radius: 23px; background: #FFFDF9; box-shadow: 0 0 0 1.5px #11615C; display: flex; align-items: center; gap: 10px; padding: 0 8px 0 16px; font: 500 15px %s;">%s'
            '<span style="flex: 1; color: %s;">%s</span><span role="button" aria-label="Clear search" style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; color: #6A6273;">%s</span></div>') % (
        WF, sv(SEARCH_I, 18), '#241F2B' if q else '#6A6273', q or 'Search titles, notes and subtasks', sv(X_I, 14) if q else '')
SCHED = btn('Schedule')
def search_results():
    return column(h1('Search', 'Everything you&#39;ve planned', '4 results') + sfield('roadmap') + schips()
                  + ghead('Tue 3 Nov · Today', True) + card(trow(IND, 'Deep work: roadmap', '9:00–11:00 AM', last=True))
                  + ghead('Thu 5 Nov') + card(trow(VIO, 'Roadmap review with Sam', '2:00–2:30 PM', last=True))
                  + ghead('Mon 2 Nov') + card(trow(BLU, 'Roadmap notes from the team', '4:00–4:30 PM · Done', True, last=True))
                  + ghead('Inbox') + card(trow(GRN, 'Share the roadmap draft', 'Inbox · 20 min', end=SCHED, last=True)), 640, 24)
def search_none(minimal=False):
    rec = ''.join('<span role="button" aria-label="Search for %s again" style="height: 32px; padding: 0 12px; border-radius: 16px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.12); display: flex; align-items: center; gap: 6px; font: 600 13px %s;">%s%s</span>' % (q, WF, sv(CLOCK, 13), q) for q in ['dentist', 'roadmap', 'parcel'])
    return column(h1('Search', 'Everything you&#39;ve planned', 'No results') + sfield('car service invoice') + schips('Done')
                  + '<div style="margin-top: 40px; text-align: center;"><div style="font: 800 20px %s;">No matches for “car service invoice”</div><div style="font: 500 14px %s; color: #4E4757; margin-top: 6px;">Try fewer words, or another filter.</div><div style="margin-top: 14px;">%s</div></div>' % (WF, WF, btn('Show all'))
                  + '<div style="margin-top: 36px; font: 800 12px %s; letter-spacing: .8px; color: #4E4757;">RECENT</div><div style="display: flex; gap: 8px; margin-top: 10px;">%s</div>' % (WF, rec), 640, 24)
MAC_TB_SEARCH = '<span style="font: 600 15px %s;">Search</span>' % MF
M_SEARCH = mac_win('Search', MAC_TB_SEARCH, search_results())
W_SEARCH0 = web_win('Search', '/#/search', search_none())
PAL = ('<div role="dialog" aria-label="Search or run" style="position: absolute; left: 50%; top: 90px; transform: translateX(-50%); width: 560px; border-radius: 22px; background: #FBF7F1; box-shadow: 0 0 0 0.5px rgba(36,31,43,0.25), 0 18px 40px rgba(36,31,43,0.28); overflow: hidden; font: 13px ' + MF + ';">'
       '<div style="display: flex; align-items: center; gap: 9px; height: 50px; padding: 0 16px; box-shadow: 0 1px 0 #E7E3EA; font: 15px ' + WF + ';">' + sv(SEARCH_I, 16) + '<span>road<span style="display: inline-block; width: 1.5px; height: 18px; background: #11615C; vertical-align: -3px;"></span></span></div>'
       '<div role="listbox" style="padding: 6px;"><div style="padding: 6px 10px 4px; font-size: 11px; font-weight: 600; color: #6A6273;">Tasks</div>'
       + ''.join('<div role="option" aria-selected="%s" style="height: 36px; display: flex; align-items: center; gap: 10px; padding: 0 10px; border-radius: 10px;%s">%s<span style="flex: 1; font-weight: 600;">%s</span><span class="num" style="font-size: 12px; color: #4E4757;">%s</span></div>' % (
           'true' if i == 0 else 'false', ' background: rgba(17,97,92,.10);' if i == 0 else '', dot(c, False).replace('18px', '14px'), t, m) for i, (c, t, m) in enumerate([(IND, 'Deep work: roadmap', 'Tue 3 Nov · 9:00–11:00 AM'), (VIO, 'Roadmap review with Sam', 'Thu 5 Nov · 2:00–2:30 PM'), (GRN, 'Share the roadmap draft', 'Inbox · 20 min')]))
       + '<div style="padding: 8px 10px 4px; font-size: 11px; font-weight: 600; color: #6A6273;">Commands</div>'
       + '<div role="option" style="height: 34px; display: flex; align-items: center; gap: 10px; padding: 0 10px; border-radius: 10px;">' + sv(SEARCH_I, 14) + '<span style="flex: 1;">Search for “road”</span><span style="font-size: 11px; color: #4E4757;">↵</span></div>'
       '</div><div style="padding: 8px 16px; box-shadow: 0 -1px 0 #E7E3EA; font-size: 11.5px; color: #6A6273;">↑↓ to move · ↵ to open · esc to close</div></div>')
M_PAL = mac_win('Today', '<span style="font: 600 15px %s;">Today</span>' % MF, '<div style="position: absolute; inset: 0; opacity: .5;">%s</div>' % column(h1('Tuesday 3 November', '3 of 9 done · 7 h 40 planned') + card(''.join(trow(c, t, m, d) for c, t, m, d in [(COR, 'Morning run', '6:45–7:30 AM', True), (AMB, 'Coffee and plan the day', '7:30–7:45 AM', True), (BLU, 'Team standup', '8:00–8:15 AM', True), (IND, 'Deep work: roadmap', '9:00–11:00 AM', False)]))) + PAL)

# ---------------------------------------------------------------- 2 · Routines, Focus, Trash
def rstep(t, m, c): return '<span style="display: inline-flex; align-items: center; gap: 6px; height: 28px; padding: 0 10px; border-radius: 14px; background: #F3ECE2; font: 600 12.5px %s;"><span style="width: 10px; height: 10px; border-radius: 50%%; background: %s;"></span>%s<span class="num" style="color: #6A6273; font-weight: 500;">%s</span></span>' % (WF, c, t, m)
def rcard2(name, summary, steps):
    return card('<div style="display: flex; align-items: center; gap: 10px;"><span style="flex: 1;"><span style="display: block; font: 800 17px %s;">%s</span><span class="num" style="display: block; font: 500 13px %s; color: #6A6273;">%s</span></span>%s%s</div>'
                '<div style="display: flex; flex-wrap: wrap; gap: 6px; margin-top: 12px;">%s</div>' % (WF, name, WF, summary, btn('Edit'), btn('Drop on today', True), ''.join(rstep(*s) for s in steps)), '16px 18px')
ROUT = column(h1('Routines', 'Reusable slices of thread', '2 routines')
              + '<div style="display: flex; flex-direction: column; gap: 12px; margin-top: 18px;">%s%s</div>' % (
                  rcard2('Morning', '4 steps · 1 h 20 · starts at Wake Up', [('Stretch', '10 min', COR), ('Morning run', '45 min', COR), ('Shower', '10 min', BLU), ('Coffee and plan the day', '15 min', AMB)]),
                  rcard2('Evening', '3 steps · 50 min · ends at Wind Down', [('Tidy up', '15 min', GRN), ('Read', '30 min', VIO), ('Lights out', '5 min', IND)]))
              + '<div style="margin-top: 12px; border-radius: 18px; box-shadow: inset 0 0 0 1.5px rgba(36,31,43,.18); padding: 16px 18px; display: flex; align-items: center; gap: 10px;">%s<span><span style="display: block; font: 700 15px %s; color: #0B4642;">New routine</span><span style="display: block; font: 500 13px %s; color: #6A6273;">or save a selection from any day</span></span></div>' % (sv(PLUS, 20), WF, WF)
              + '<div style="margin-top: 14px; font: 500 13px %s; color: #6A6273;">Routine-start dots ring loud, like an alarm</div>' % WF, 640, 24)
M_ROUT = mac_win('Routines', '<span style="font: 600 15px %s;">Routines</span>' % MF, ROUT)


def focus_body(web=False):
    ring = ('<div style="position: relative; width: 220px; height: 220px; margin: 22px auto 0;"><svg width="220" height="220" viewBox="0 0 220 220" aria-hidden="true"><circle cx="110" cy="110" r="96" fill="none" stroke="#E4E3F7" stroke-width="14"></circle>'
            '<circle cx="110" cy="110" r="96" fill="none" stroke="#5A4FCF" stroke-width="14" stroke-linecap="round" stroke-dasharray="603" stroke-dashoffset="90" transform="rotate(-90 110 110)"></circle></svg>'
            '<div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center;"><span class="num" style="font: 800 40px %s;">18</span><span style="font: 600 14px %s; color: #4E4757;">min left</span></div></div>') % (WF, WF)
    deep = (('<div style="display: flex; align-items: center; gap: 10px; padding: 12px 16px;"><span style="flex: 1;"><span style="display: block; font: 700 14px %s;">Deep work</span><span style="display: block; font: 500 12.5px %s; color: #6A6273;">Use your computer&#39;s Do Not Disturb; the browser can&#39;t change it</span></span></div>') % (WF, WF)
            if web else ('<div style="display: flex; align-items: center; gap: 10px; padding: 12px 16px;"><span style="flex: 1; font: 700 14px %s;">Deep work · Focus on</span>%s</div>' % (WF, sv(CHEV, 16))))
    return ('<div style="height: 100%%; display: flex; flex-direction: column; align-items: center; padding-top: 18px; font-family: %s; color: #241F2B;">'
            '<div style="width: 560px; display: flex; align-items: center;"><span style="font: 600 14px %s; color: #11615C; display: flex; align-items: center; gap: 4px;">%sToday</span><span style="flex: 1; text-align: center; font: 700 15px %s;">Focus</span><span style="font: 600 14px %s; color: #11615C;">More</span></div>'
            '<div style="margin-top: 16px; font: 800 26px %s;">Deep work: roadmap</div><div class="num" style="font: 500 14px %s; color: #4E4757; margin-top: 2px;">9:00–11:00 AM · 2 h</div>%s'
            '<div style="margin-top: 18px; width: 420px;"><div style="font: 800 12px %s; letter-spacing: .8px; color: #4E4757;">STEP 2 OF 3 · OUTLINE THE SECTIONS</div><div style="display: flex; gap: 6px; margin-top: 8px;"><span style="flex: 1; height: 6px; border-radius: 3px; background: #5A4FCF;"></span><span style="flex: 1; height: 6px; border-radius: 3px; background: #A9A3E8;"></span><span style="flex: 1; height: 6px; border-radius: 3px; background: #E4E3F7;"></span></div></div>'
            '<div style="display: flex; gap: 10px; margin-top: 20px;">%s%s%s</div>'
            '<div style="margin-top: 20px; width: 420px;">%s</div><div style="margin-top: 10px; font: 500 12.5px %s; color: #6A6273;">Dot starts still break through Focus (time-sensitive)</div></div>') % (
        WF, WF, sv('<path d="M15 6l-6 6 6 6"></path>', 15), WF, WF, WF, WF, ring, WF, btn('Done', True), btn('+15 min'), btn('Next step'),
        card('<div style="display: flex; align-items: center; gap: 10px; padding: 12px 16px; box-shadow: inset 0 -1px 0 rgba(36,31,43,.06);"><span style="flex: 1; font: 700 14px %s;">Chime every 15 min</span>%s</div>%s' % (WF, ios_switch(True).replace('#11615C', '#11615C'), deep), '0'), WF)
M_FOCUS = mac_win('Today', '<span style="font: 600 15px %s;">Focus</span><span style="flex: 1;"></span><span style="font: 12px %s; color: #6A6273;">esc to leave</span>' % (MF, MF), focus_body())
W_FOCUS = web_win('Today', '/#/focus/0193a1c2…', focus_body(True))


# Settings window (approved G2-4, ED-084): the toolbar of panes, one selected, with the ED-332 icons.
PANES = ['General', 'Your day', 'Planning', 'Reminders', 'Appearance', 'Data and privacy', 'Help']
PANE_ICON = {'General': 'General', 'Help': 'Help and about'}
def setwin(sel, title, body, w=900):
    tb = ''.join('<span style="display: flex; flex-direction: column; align-items: center; gap: 3px; padding: 6px 10px; border-radius: 8px; font-size: 11.5px;%s">%s%s</span>' % (
        ' background: rgba(36,31,43,.08); color: #0B4642; font-weight: 600;' if p == sel else ' color: #4E4757;',
        stile(PANE_ICON.get(p, p), 22, 6, 14) if PANE_ICON.get(p, p) in ICONS else '<span aria-hidden="true" style="width: 22px; height: 22px; border-radius: 6px; background: #E2EFEC;"></span>', p) for p in PANES)
    return ('<div role="img" aria-label="Mac Settings window, %s" style="width: %dpx; border-radius: 14px; background: #FBF7F1; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.18), 0 24px 50px rgba(36,31,43,.18); font: 13px %s; color: #241F2B; position: relative;">'
            '<div style="background: #F3ECE2; box-shadow: 0 1px 0 rgba(36,31,43,.10); padding: 10px 14px 6px;"><div style="display: flex; align-items: center; justify-content: center; position: relative; height: 22px; font-weight: 600;"><span aria-hidden="true" style="position: absolute; left: 0; display: flex; gap: 8px;"><span style="width: 12px; height: 12px; border-radius: 50%%; background: #EC6A5E;"></span><span style="width: 12px; height: 12px; border-radius: 50%%; background: #F4BF4F;"></span><span style="width: 12px; height: 12px; border-radius: 50%%; background: #61C554;"></span></span>%s</div>'
            '<div style="display: flex; justify-content: center; gap: 2px; margin-top: 6px;">%s</div></div><div style="padding: 18px 24px 22px; min-height: 340px; position: relative;">%s</div></div>') % (title, w, MF, title, tb, body)
def mrow(t, sub=None, val=None, sw=None, chev=True, last=False, color=None):
    ic = stile(t) if t in ICONS else ''
    end = (ios_switch(sw) if sw is not None else ('<span class="num" style="color: #6A6273;">%s</span>' % val if val else '') + (sv(CHEV, 12) if chev else ''))
    return ('<div style="min-height: 44px; display: flex; align-items: center; gap: 12px; padding: 6px 14px;%s">%s<span style="flex: 1;"><span style="display: block; font-size: 13.5px;%s">%s</span>%s</span>%s</div>') % (
        '' if last else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.12);', ic, (' color: %s; font-weight: 600;' % color) if color else '', t,
        ('<span style="display: block; font-size: 12px; color: #6A6273;">%s</span>' % sub) if sub else '', end)
def mgroup(cap, rows): return ('<div style="font-size: 11.5px; font-weight: 600; color: #6A6273; margin: 4px 4px 6px;">%s</div>' % cap if cap else '') + '<div style="border-radius: 12px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); overflow: hidden; margin-bottom: 14px;">%s</div>' % ''.join(rows)
DP = mgroup('Data', [mrow('Sync', val='Synced'), mrow('Calendars', 'Events on your timeline'), mrow('Export'), mrow('Trash', 'Deleted tasks stay 30 days', last=True)])
def mdialog(title, inner, w=460, top=70):
    return ('<div style="position: absolute; inset: 0; background: rgba(36,31,43,.18);"></div><div role="dialog" aria-label="%s" style="position: absolute; left: 50%%; top: %dpx; transform: translateX(-50%%); width: %dpx; border-radius: 16px; background: #FBF7F1; box-shadow: 0 0 0 0.5px rgba(36,31,43,.3), 0 20px 50px rgba(36,31,43,.3); padding: 16px 18px;">'
            '<div style="display: flex; align-items: center;"><span style="flex: 1; font: 700 15px %s;">%s</span><span role="button" aria-label="Close" style="color: #6A6273;">%s</span></div>%s</div>') % (title, top, w, MF, title, sv(X_I, 14), inner)
TRASH_ROWS = [('Pick up parcel', GRN, 'Deleted today · 30 days left'), ('Dentist', GRY, 'Deleted yesterday · 29 days left'), ('Old: book flights', BLU, 'Deleted 12 Oct · 8 days left'), ('Call the bank', AMB, 'Deleted 9 Oct · 5 days left')]
TRASH = mdialog('Trash', '<div style="margin-top: 10px; border-radius: 12px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); overflow: hidden;">%s</div>' % ''.join(
    '<div style="min-height: 48px; display: flex; align-items: center; gap: 10px; padding: 6px 12px;%s">%s<span style="flex: 1;"><span style="display: block; font: 600 13.5px %s;">%s</span><span style="display: block; font-size: 12px; color: #6A6273;">%s</span></span>%s</div>' % (
        '' if i == len(TRASH_ROWS) - 1 else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.12);', dot(c, False).replace('18px', '14px'), MF, t, s, btn('Restore', f=MF)) for i, (t, c, s) in enumerate(TRASH_ROWS)), 480, 40)
M_TRASH = setwin('Data and privacy', 'Data and privacy', '<div style="opacity: .5;">%s</div>%s' % (DP, TRASH))

# ---------------------------------------------------------------- 3 · 3 days and Month (Full)
HOURS = list(range(8, 21))
DAYS3 = [('Monday 2 November · Yesterday', '4 of 4', [(COR, 'Morning run', 6.75, 7.5, True), (BLU, 'Team standup', 8, 8.25, True), (IND, 'Write the brief', 9, 11, True), (PNK, 'Lunch', 12.5, 13.25, True), (BLU, 'Roadmap notes from the team', 16, 16.5, True)]),
         ('Tuesday 3 November · Today', '3 of 9', [(BLU, 'Team standup', 8, 8.25, True), (IND, 'Deep work: roadmap', 9, 11, False), (GRN, 'Call with Sam', 10.5, 11, False), (PNK, 'Lunch', 12.5, 13.25, False), (GRY, 'Dentist', 14, 14.5, False), (GRN, 'Pick up parcel', 15, 15.75, False), (VIO, 'Gym', 18, 19, False)]),
         ('Wednesday 4 November · Tomorrow', '0 of 3', [(BLU, 'Team standup', 8, 8.25, False), (VIO, 'Roadmap review with Sam', 14, 14.5, False), (VIO, 'Gym', 18, 19, False)])]
PX = 46
def three_days():
    cols = ''
    for i, (title, done, tasks) in enumerate(DAYS3):
        cards = ''.join('<div style="position: absolute; left: %dpx; right: 6px; top: %dpx; height: %dpx; border-radius: 10px; background: %s; box-shadow: inset 3px 0 0 %s; padding: 3px 8px; box-sizing: border-box; overflow: hidden; font: 600 12px %s; color: #241F2B;%s">%s</div>' % (
            44 if (t == 'Call with Sam') else 6, (a - 8) * PX + 1, max(18, (b - a) * PX - 2), '#FFFDF9', c, WF, ' text-decoration: line-through; color: #6A6273;' if d else '', t) for c, t, a, b, d in tasks if a >= 8)
        now = '<div style="position: absolute; left: 0; right: 0; top: %dpx; height: 2px; background: #11615C;"><span class="num" style="position: absolute; left: -2px; top: -9px; padding: 0 5px; border-radius: 8px; background: #11615C; color: #fff; font: 700 11px %s;">10:42</span></div>' % ((10.7 - 8) * PX, WF) if i == 1 else ''
        cols += ('<div style="flex: 1; min-width: 0;%s"><div style="height: 52px; padding: 8px 10px; box-sizing: border-box; box-shadow: 0 1px 0 rgba(36,31,43,.08);"><div style="font: 800 13px %s;%s">%s</div><div class="num" style="font: 500 12px %s; color: #6A6273;">%s done</div></div>'
                 '<div style="position: relative; height: %dpx;">%s%s</div></div>') % (' background: rgba(17,97,92,.04);' if i == 1 else '', WF, ' color: #0B4642;' if i == 1 else '', title, WF, done, len(HOURS) * PX, cards, now)
    axis = '<div style="width: 46px; flex: none; padding-top: 52px;">%s</div>' % ''.join('<div class="num" style="height: %dpx; font: 500 11px %s; color: #6A6273; text-align: right; padding-right: 6px; box-sizing: border-box; margin-top: -6px;">%s</div>' % (PX, WF, ('%d AM' % h) if h < 12 else ('12 PM' if h == 12 else '%d PM' % (h - 12))) for h in HOURS)
    lines = '<div aria-hidden="true" style="position: absolute; left: 46px; right: 0; top: 52px; bottom: 0; background: repeating-linear-gradient(to bottom, rgba(36,31,43,.06) 0 1px, transparent 1px %dpx);"></div>' % PX
    return '<div style="position: relative; display: flex; height: 100%%; font-family: %s;">%s%s<div style="flex: 1; display: flex; gap: 0;">%s</div></div>' % (WF, lines, axis, cols)
def range_tabs(sel):
    return ('<div role="tablist" style="display: flex; height: 30px; border-radius: 21px; background: rgba(36,31,43,.06); padding: 2px; box-sizing: border-box; gap: 2px;">%s</div>' % ''.join(
        '<span role="tab" aria-selected="%s" style="padding: 0 12px; border-radius: 19px; display: flex; align-items: center; font: %s 12px %s; %s">%s</span>' % (
            'true' if t == sel else 'false', '600' if t == sel else '500', MF, 'background: #FFFDF9; box-shadow: 0 1px 3px rgba(36,31,43,.16); color: #241F2B;' if t == sel else 'color: #4E4757;', t) for t in ['Day', '3 days', 'Week', 'Month']))
def navpill(label): return ('<span style="display: flex; align-items: center; height: 30px; border-radius: 21px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); font: 500 13px %s;"><span style="width: 30px; display: flex; justify-content: center; color: #4E4757;">%s</span>Today<span style="width: 30px; display: flex; justify-content: center; color: #4E4757;">%s</span></span>'
                            '<span style="height: 30px; padding: 0 12px; border-radius: 21px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: flex; align-items: center; font: 600 15px %s;">%s</span>') % (MF, sv('<path d="M15 6l-6 6 6 6"></path>', 14), sv(CHEV, 14), MF, label)
M_3D = mac_win('3 days', navpill('2–4 Nov 2026') + range_tabs('3 days'), three_days())

MDATA = {2: ([('Morning run', 1), ('Write the brief', 1), ('Team standup', 1)], 4, 4), 3: ([('Deep work: roadmap · now', 0), ('Call with Sam', 0), ('Lunch', 0)], 3, 9), 4: ([('Team standup', 0), ('Roadmap review with Sam', 0), ('Gym', 0)], 0, 3),
         5: ([('Team standup', 0), ('Dentist follow-up', 0)], 0, 2), 6: ([('Team standup', 0), ('Pick up parcel', 0), ('Gym', 0), ('Dinner with Ana', 0), ('Read', 0)], 0, 5), 7: None, 8: None,
         9: ([('Team standup', 0), ('Plan the week', 0)], 0, 2), 10: ([('Team standup', 0), ('Car service', 0), ('Gym', 0)], 0, 3), 11: ([('Team standup', 0)], 0, 1), 12: ([('Team standup', 0), ('Read', 0)], 0, 2), 13: ([('Team standup', 0), ('Gym', 0)], 0, 2)}
OCT = {26: 3, 27: 5, 28: 4, 29: 2, 30: 6, 31: 1}
def month_cards(stats=True, w=1064):
    cells = []
    for d in list(range(26, 32)) + list(range(1, 31)) + [1, 2, 3, 4, 5, 6]:
        other = len(cells) < 6 or len(cells) >= 36
        data = None if other else MDATA.get(d, 'light')
        body = ''
        if data == 'light' or data is None and not other:
            body = '<div style="font: 500 11.5px %s; color: #6A6273; margin-top: 4px;">Light day</div>' % WF
        elif data:
            items, done, total = data
            shown = items[:3]
            body = ''.join('<div style="font: 600 11.5px/16px %s; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;%s">%s</div>' % (WF, ' text-decoration: line-through; color: #6A6273;' if dn else '', t) for t, dn in shown)
            if len(items) > 3:
                body += '<div style="font: 600 11.5px %s; color: #11615C;">+%d more</div>' % (WF, len(items) - 3)
            body += '<div class="num" style="font: 500 11px %s; color: #6A6273; margin-top: 2px;">%d of %d done</div>' % (WF, done, total)
        today = (d == 3 and not other)
        cells.append('<div role="gridcell" style="min-height: 104px; border-radius: 12px; padding: 6px 8px; box-sizing: border-box; overflow: hidden; %s"><div class="num" style="font: 800 13px %s;%s">%s</div>%s</div>' % (
            'background: transparent; opacity: .45;' if other else ('background: #FFFDF9; box-shadow: 0 0 0 1.5px #11615C;' if today else 'background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.07);'),
            WF, ' color: #0B4642;' if today else '', d, body))
    head = ''.join('<div style="font: 700 11px %s; color: #6A6273; padding: 0 8px;">%s</div>' % (WF, x) for x in ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'])
    st = ('<div style="display: flex; align-items: flex-end; margin-bottom: 12px;"><div><div style="font: 800 26px %s;">November 2026</div><div class="num" style="font: 500 13px %s; color: #4E4757;">7 done · 0 not done · 32 ahead · busiest day Fri 6</div></div></div>' % (WF, WF)) if stats else ''
    return '<div style="padding: 16px 20px; box-sizing: border-box; font-family: %s;">%s<div style="display: grid; grid-template-columns: repeat(7, 1fr); gap: 6px;">%s%s</div></div>' % (WF, st, head, ''.join(cells))
def week_month(sel): return ('<span role="tablist" style="display: flex; height: 30px; border-radius: 21px; background: rgba(36,31,43,.06); padding: 2px; box-sizing: border-box; gap: 2px;">%s</span>' % ''.join(
    '<span role="tab" aria-selected="%s" style="padding: 0 12px; border-radius: 19px; display: flex; align-items: center; font: %s 12px %s; %s">%s</span>' % ('true' if t == sel else 'false', '600' if t == sel else '500', MF, 'background: #FFFDF9; box-shadow: 0 1px 3px rgba(36,31,43,.16);' if t == sel else 'color: #4E4757;', t) for t in ['Week', 'Month']))
M_MONTH = mac_win('Month', navpill('November 2026') + range_tabs('Month'), month_cards())

# ---------------------------------------------------------------- 4 · Minimal on wide: Inbox, Calendar, Search
INB = [('Share the roadmap draft', '20 min', GRN), ('Book the car service', '15 min', AMB), ('Call the bank', '10 min', AMB)]
MIN_INBOX = column(h1('Inbox', '3 unscheduled · 45 min of work', '3') +
                   '<div style="margin-top: 14px; border-radius: 16px; background: #E2EFEC; padding: 12px 16px; font: 600 14px %s; color: #0B4642;">Next free slot today: 4:00–4:30 PM · fits Share the roadmap draft</div>' % WF
                   + '<div style="margin-top: 12px;">%s</div>' % card(''.join(trow(c, t, m, end=btn('Place'), last=(i == len(INB) - 1)) for i, (t, m, c) in enumerate(INB))), 600, 28)
MIN_CAL = '<div style="display: flex; align-items: center; gap: 8px; padding: 12px 20px 0;">%s<span style="flex: 1;"></span>%s</div>' % (week_month('Month'), navpill('November 2026').split('</span><span style="height: 30px')[0] + '</span>') + month_cards()
W_MIN_INBOX = min_win('Inbox', '/#/inbox', MIN_INBOX)
W_MIN_CAL = min_win('Calendar', '/#/month/2026-11', MIN_CAL)
W_MIN_SEARCH = min_win('Search', '/#/search', search_results())

# ---------------------------------------------------------------- 5 · Menus, Settings panes, Copy to which day
def mmenu(name, items, left):
    rows = ''.join('<div style="height: 1px; background: rgba(36,31,43,.12); margin: 4px 8px;"></div>' if it == '-' else '<div role="menuitem" style="height: 22px; display: flex; align-items: center; justify-content: space-between; padding: 0 10px; border-radius: 5px;%s"><span>%s</span><span style="color: #6A6273;">%s</span></div>' % (
        ' background: #2F7DF6; color: #fff;' if i == 0 and name == 'Edit' else '', it[0], it[1]) for i, it in enumerate(items))
    return '<div role="menu" aria-label="%s" style="position: absolute; left: %dpx; top: 26px; width: 200px; border-radius: 0 0 8px 8px; background: #FBF7F1; box-shadow: 0 10px 26px rgba(36,31,43,.2), 0 0 0 .5px rgba(36,31,43,.2); padding: 5px;">%s</div>' % (name, left, rows)
def menubar(open_):
    items = ['Dottoday', 'File', 'Edit', 'View', 'Go', 'Window', 'Help']
    return '<div style="height: 26px; display: flex; align-items: center; gap: 14px; padding: 0 12px; background: #F6F1EA; box-shadow: 0 1px 0 rgba(36,31,43,.08);">%s</div>' % ''.join(
        '<span style="%s">%s</span>' % ('font-weight: 700;' if i == 0 else ('padding: 1px 7px; margin: 0 -7px; border-radius: 4px; background: #11615C; color: #fff;' if it == open_ else ''), it) for i, it in enumerate(items))
def menu_inset(name, items, left):
    return '<div style="position: relative; width: 560px; height: %dpx; border-radius: 18px; background: #FBF7F1; box-shadow: 0 0 0 1px rgba(36,31,43,.12); overflow: hidden; font: 13px %s; color: #241F2B;">%s%s</div>' % (
        64 + 22 * len(items), MF, menubar(name), mmenu(name, items, left))
EDIT = menu_inset('Edit', [('Undo', ''), ('Redo', ''), '-', ('Delete', '')], 118)
WINDOW = menu_inset('Window', [('Minimize', '⌘M'), ('Zoom', ''), '-', ('Bring All to Front', '')], 238)

HELP_P = setwin('Help', 'Help and about', mgroup('About', [mrow('Help'), mrow('Privacy'), mrow('About Dottoday', val='1.2.0'), mrow('Send feedback', last=True)])
                + '<div style="font-size: 12px; color: #6A6273; margin: 0 4px;">Are there keyboard shortcuts? On a Mac or in a browser, press ⌘/ (Ctrl+/ elsewhere) to see them all.</div>')
def calrow(c, t, sub=None, on=True, last=False):
    return ('<div style="min-height: 44px; display: flex; align-items: center; gap: 12px; padding: 6px 14px;%s"><span style="width: 12px; height: 12px; border-radius: 50%%; background: %s; margin: 0 9px;"></span><span style="flex: 1;"><span style="display: block; font-size: 13.5px;">%s</span>%s</span>%s</div>') % (
        '' if last else ' box-shadow: inset 0 -0.5px 0 rgba(36,31,43,.12);', c, t, ('<span style="display: block; font-size: 12px; color: #6A6273;">%s</span>' % sub) if sub else '', ios_switch(on))
CAL_P = setwin('Data and privacy', 'Calendars', '<div style="font-size: 12.5px; color: #4E4757; margin: 0 4px 12px;">Your calendar events on the timeline, next to your tasks. Free, always.</div>'
               + mgroup('On this Mac', [calrow(BLU, 'Work'), calrow(GRN, 'Family'), calrow(GRY, 'Holidays', 'Read-only', False, True)])
               + mgroup(ACCT, [calrow(VIO, 'Personal'), mrow('Disconnect', chev=False, color='#11615C', last=True)])
               + mgroup('Google and Microsoft', [mrow('Connect Microsoft Outlook', chev=False, color='#11615C', last=True)]))
LOCK_P = setwin('Data and privacy', 'Privacy', mgroup('APP LOCK', [mrow('Lock Dottoday', 'Ask for your face, fingerprint or passcode', sw=True), mrow('Lock after', val='1 minute', last=True)])
                + '<div style="font: 700 13px %s; margin: 6px 4px 2px;">On your device</div><div style="font-size: 12.5px; color: #4E4757; margin: 0 4px;">Tasks are stored encrypted on this device, and the app works fully offline.</div>' % MF)
WEB_CAL = column(h1('Calendars', None) + '<div style="font: 500 14px %s; color: #4E4757; margin: 6px 0 14px;">Your calendar events on the timeline, next to your tasks. Free, always.</div>' % WF
                 + '<div style="font: 700 12px %s; color: #6A6273; margin: 0 4px 6px;">Google and Microsoft</div>' % WF
                 + card(''.join('<div style="min-height: 52px; display: flex; align-items: center; gap: 12px; padding: 6px 16px;%s">%s<span style="flex: 1; font: 700 15px %s; color: %s;">%s</span></div>' % (
                     '' if i == 2 else ' box-shadow: inset 0 -1px 0 rgba(36,31,43,.06);', stile(t), WF, '#11615C' if 'Connect' in t else '#241F2B', t) for i, t in enumerate(['No calendars connected yet', 'Connect Google Calendar', 'Connect Microsoft Outlook'])))
                 + '<div style="font: 500 13px %s; color: #6A6273; margin: 10px 4px;">Connected once, they show on every device you sign in on. If a calendar is also on this device, switch one of the two off.</div>' % WF, 600, 28)
W_CAL = web_win('Settings', '/#/settings/calendars', WEB_CAL)


def copy_dialog():
    m = a_month().replace(AF, WF).replace('height: 44px; border-radius: 22px', 'height: 38px; border-radius: 19px').replace('<div style="font: 400 22px/28px %s; color: #241F2B; margin-bottom: 12px;">Copy to which day?</div>' % WF, '')
    return mdialog('Copy to which day?', '<div style="margin-top: 12px;">%s</div>' % m, 420, 40)
M_COPY = mac_win('Today', '<span style="font: 600 15px %s;">Today</span>' % MF, '<div style="position: absolute; inset: 0;">%s</div>%s' % (
    column(h1('Tuesday 3 November', '3 of 9 done · 7 h 40 planned') + card(''.join(trow(c, t, m, d) for c, t, m, d in [(COR, 'Morning run', '6:45–7:30 AM', True), (AMB, 'Coffee and plan the day', '7:30–7:45 AM', True), (BLU, 'Team standup', '8:00–8:15 AM', True), (IND, 'Deep work: roadmap', '9:00–11:00 AM', False), (GRN, 'Call with Sam', '10:30–11:00 AM', False)]))), copy_dialog()))
M_COPIED = mac_win('Today', '<span style="font: 600 15px %s;">Today</span>' % MF, column(h1('Tuesday 3 November', '3 of 9 done · 7 h 40 planned') + card(''.join(trow(c, t, m, d) for c, t, m, d in [(COR, 'Morning run', '6:45–7:30 AM', True), (AMB, 'Coffee and plan the day', '7:30–7:45 AM', True), (BLU, 'Team standup', '8:00–8:15 AM', True), (IND, 'Deep work: roadmap', '9:00–11:00 AM', False)])))
                   + '<div role="status" style="position: absolute; left: 50%; bottom: 28px; transform: translateX(-50%); min-width: 320px; height: 44px; border-radius: 22px; background: #322F37; color: #F5EFF7; display: flex; align-items: center; gap: 12px; padding: 0 8px 0 18px; font: 500 13.5px ' + WF + ';"><span style="flex: 1;">Copied 8 tasks</span><span role="button" style="font-weight: 700; color: #A3E2D9; padding: 0 10px;">Undo</span></div>')

# ---------------------------------------------------------------- page
def scw(fr, w, h, s):
    return '<div style="width: %dpx; height: %dpx; flex: none;"><div style="width: %dpx; height: %dpx; transform: scale(%s); transform-origin: 0 0;">%s</div></div>' % (round(w * s), round(h * s), w, h, s, fr)
WS = 0.64
def fw(lab, fr, *n, w=1280, h=800, s=WS): return col(round(w * s), label(lab), scw(fr, w, h, s), notes(*n))
def fs(lab, fr, *n, w=900, h=470, s=0.62): return col(round(w * s), label(lab), scw(fr, w, h, s), notes(*n))
B, D, P, Q = (lambda t: tag('tb', t)), (lambda t: tag('td', t)), (lambda t: tag('tn', t)), (lambda t: tag('th', t))
row = lambda *c: '<div style="display: flex; gap: 40px; align-items: flex-start; flex-wrap: wrap;">%s</div>' % ''.join(c)
SHELL = D('Design-only') + ' The approved Workspace shell (E-FullA-v2, ED-084, ED-093); the content is built'
s1 = row(fw('Mac · Search with results', M_SEARCH, B('Built') + ' One centred column; results grouped by day, Today first, then Inbox with Schedule; filters All, Today, This week, Inbox, Done, Colour, Icon', SHELL),
         fw('Web · Search with no results', W_SEARCH0, B('Built') + ' “No matches for …”, “Try fewer words, or another filter.”, Show all when a filter is on, Recent below', B('Built') + ' Web route /#/search; / focuses it'))
s1b = row(fw('Mac · Search or run, typing', M_PAL, P('Not built') + ' There is no command palette in the app (no ⌘K, no Ctrl K)', D('Design-only') + ' Results while typing: Tasks, then Search for “…”; the approved palette (E-FullA-v2, E-Minimal) with no new copy beyond its own'),
          fw('Mac · Routines', M_ROUT, B('Built') + ' Routines page in the content area: Edit, Drop on today, New routine, the alarm note', B('Built') + ' Reached from the sidebar here; in the app from Settings › Planning, the day’s ⋯ and the Inbox; web /#/settings/routines'))
s2 = row(fw('Mac · Focus (the whole window, ED-285)', M_FOCUS, B('Built') + ' Focus fills the content area at expanded width; esc leaves', B('Built') + ' Deep work · Focus on opens “Turn on Focus with Shortcuts”'),
         fw('Web · Focus', W_FOCUS, B('Built') + ' The same screen; Deep work has no switch: “Use your computer’s Do Not Disturb; the browser can’t change it”'))
s2b = row(fs('Mac · Settings › Data and privacy › Trash', M_TRASH, B('Built') + ' Trash opens as a centred dialog over Settings (a sheet on phones); rows with Restore', B('Built') + ' The same on web', D('Design-only') + ' Settings as its own window (ED-084); in the app ⌘, opens the Settings page'),
          fs('Mac · Settings › Help and about', HELP_P, B('Built') + ' Help, Privacy, About Dottoday with the version, Send feedback; no Siri row on Mac or web', B('Built') + ' Send feedback is a dialog on Mac and web; mailto, subject “Dottoday feedback”'),
          fs('Mac · Settings › Calendars', CAL_P, B('Built') + ' Mac reads its own calendars; Google and Microsoft below; Disconnect for accounts only', h=640))
s3 = row(fw('Mac · 3 days', M_3D, B('Built') + ' Yesterday, today and tomorrow, “· Yesterday / · Today / · Tomorrow”; ‹ › step one day; tasks drag between columns', D('Design-only') + ' On the approved hour canvas with the 3 days tab; in the app this is Today’s spread'),
         fw('Mac · Month', M_MONTH, B('Built') + ' Month cards at expanded width: titles, done struck through, “· now”, “+N more”, “N of N done”, Light day', B('Built') + ' Stats: done · not done · ahead · busiest day; ‹ Today ›; a day opens that day'))
s4 = row(fw('Web, minimal · Inbox', W_MIN_INBOX, B('Built') + ' Next free slot and Place on each row (docs/14 §3)', P('Code gap') + ' At expanded width the app still shows the full Inbox (Drop onto today, Auto-plan): to fix in code'),
         fw('Web, minimal · Calendar (Month)', W_MIN_CAL, B('Built') + ' Week | Month, ‹ Today ›; the same month cards', B('Built') + ' Calendar is reached from View › Month and ⌘4 in minimal'))
s4b = row(fw('Web, minimal · Search', W_MIN_SEARCH, B('Built') + ' Search is unchanged in minimal; reached from the sidebar here, Everything else… in the app'),
          fs('Mac · Settings › Privacy', LOCK_P, B('Built') + ' Lock Dottoday and Lock after on Mac; web has no switch (R2-24)'))
s5 = row(col(560, label('Mac · Edit menu'), EDIT, notes(B('Built') + ' Undo, Redo, Delete with no keys shown, so text fields keep ⌘Z, ⇧⌘Z and ⌫; the keys still work', B('Built') + ' Delete moves the picked tasks to Trash; no Cut, Copy, Paste')),
         col(560, label('Mac · Window menu'), WINDOW, notes(B('Built') + ' The system items: Minimize, Zoom, Bring All to Front', B('Built') + ' Web has no menu bar; the same keys work in the browser')))
s6 = row(fw('Mac · Copy to which day?', M_COPY, B('Built') + ' A centred dialog at wide widths (a sheet on phones); tap a day and it copies at once', B('Built') + ' From the day’s ⋯ menu; not in the menu bar'),
         fw('Mac · copied', M_COPIED, B('Built') + ' “Copied 8 tasks” with Undo'), fw('Web · Settings › Calendars', W_CAL, B('Built') + ' Web: Google and Microsoft only, no device calendars'))
RULES = [('Same features (R-13)', 'Every screen that phones and tablets have is drawn on Mac and web; only the menu bar is Mac-only.'),
         ('Built, inside the approved shell', 'Content and copy are the app’s; the sidebar, Settings window and Search or run are the approved design and are marked Design-only.'),
         ('Two gaps for code', 'Search or run is not built; minimal Inbox at wide widths still shows the full Inbox.'),
         ('Calm', 'No results and an empty Trash are plain lines; copying a day has Undo.'),
         ('Icons', 'Settings rows use the ED-332 icons on Mac and web too.'),
         ('Text from the app', 'Every string is built (app_en.arb, app_menu.dart). Tasks and dates are examples. No new copy.')]
rules = '<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; max-width: 1800px;">%s</div>' % ''.join(
    '<div style="border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.08); padding: 18px;"><div style="font: 800 17px Manrope;">%s</div><div style="font: 500 14px/21px Manrope; color: #4E4757; margin-top: 6px;">%s</div></div>' % r for r in RULES)
body = ('<header style="display: flex; flex-direction: column; gap: 10px;"><div style="font: 700 14px Manrope; letter-spacing: 1px; color: #0B4642;">CONCEPT E · ROUND 2 GAP PASS · R2-30</div>'
        '<h1 style="margin: 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -1.2px;">Mac and web parity</h1>'
        '<p style="margin: 0; font-size: 19px; line-height: 29px; color: #4E4757; max-width: 1600px;">The Mac and web screens that were only described in notes: Search, Search or run, Routines, Focus, Trash, 3 days and Month, minimal Inbox, Calendar and Search, the Edit and Window menus, Settings panes and Copy to which day. As built, inside the approved shell. @@OTHER@@</p>'
        '<div style="display: flex; gap: 6px;">%s %s %s</div></header>') % (tag('th', 'Proposed · gap pass'), tag('tn', 'Mac and web'), tag('tn', '@@THEME@@'))
page_body = (body + section('1 · Search, Search or run and Routines', s1 + s1b) + section('2 · Focus, and Settings panes', s2 + s2b)
             + section('3 · 3 days and Month', s3) + section('4 · Minimal on wide', s4 + s4b) + section('5 · Menus and Copy to which day', s5 + s6) + section('Rules', rules))
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · R2-30 · Mac and web parity</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n' + AB['helmet']
        + '\n<div style="width: 1900px; height: %dpx; box-sizing: border-box; padding: 48px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px;">\n' % H
        + page_body + '\n</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":1900,"height":%d}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n' % H)
XL = dict(SYSL, NB='rgba(246,244,248,.80)', NI='#1D1B20', NS='rgba(29,27,32,.6)', NSEP='rgba(0,0,0,.12)', AACT='#11615C', MHI='#2F7DF6', APP=APPMARK, AL='rgba(242,242,247,.94)', ALB='#0B6E68', TA='#A3E2D9')
XD = dict(SYSD, NB='rgba(44,42,48,.82)', NI='#F2EEF4', NS='rgba(242,238,244,.62)', NSEP='rgba(255,255,255,.12)', AACT='#5BC4B8', MHI='#2F7DF6', APP=APPMARK, AL='rgba(44,44,46,.94)', ALB='#5BC4B8', TA='#0B4642')
light = fill(page, XL).replace('@@OTHER@@', 'Dark on E-R2-30-Dark.').replace('@@THEME@@', 'Light')
open('project/E-R2-30.dc.html', 'w', encoding='utf-8').write(light)
dk = darkify(page.replace('@@OTHER@@', 'Light on E-R2-30.').replace('@@THEME@@', 'Dark'))
dk = fill(dk, XD).replace('0 0 0 12px #F3ECE4', '0 0 0 12px #241F2B').replace('class="blk-d', 'class="blk').replace('<title>E · R2-30 · Mac and web parity</title>', '<title>E · R2-30 · Mac and web parity · Dark</title>')
open('project/E-R2-30-Dark.dc.html', 'w', encoding='utf-8').write(dk)
print('ok')
