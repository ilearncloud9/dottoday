"""Touch Workspace (R2-2): Plan panel + week grid at the ED-256 scale, built from the approved Workspace's sample data."""
import os, sys
sys.path.insert(0, '/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/808fbcc2-41cc-4f78-a14f-443da127ba4a/scratchpad/r21')
from frames import *
from frames import _ICON
F_UI = 'font-family: Manrope, system-ui, sans-serif;'
HOUR = 96; T0 = 8.0          # grid starts at 8 AM, scrolled (earlier hours above)
def y(t): return (t - T0) * HOUR

WEEK = {  # approved E-FullA-v2 / E-G4-3-Narrow sample (labels): name, start, end, colour, state
 'Mon': [('Team standup', 8, 8.25, '#4A9BD6', 'done'), ('Deep work', 9.5, 11.5, '#5B5FD6', 'done'), ('Lunch', 12.5, 13.25, '#D9668F', 'done'), ('Weekly reset', 15, 16, '#8B5CF6', 'done')],
 'Tue': [('Team standup', 8, 8.25, '#4A9BD6', 'done'), ('Deep work: roadmap', 9, 11, '#5B5FD6', 'now'), ('Call with Sam', 10.5, 11, '#2A9D8F', 'now2'),
         ('Lunch', 12.5, 13.25, '#D9668F', 'ahead'), ('Dentist', 14, 14.5, '#7A7280', 'cal'), ('Pick up parcel', 15, 15.75, '#469763', 'ahead')],
 'Wed': [('Team standup', 8, 8.25, '#4A9BD6', 'ahead'), ('Deep work', 9, 10.5, '#5B5FD6', 'ahead'), ('Lunch', 12.5, 13.25, '#D9668F', 'ahead')],
 'Thu': [('Team standup', 8, 8.25, '#4A9BD6', 'ahead'), ('Deep work', 9, 11, '#5B5FD6', 'ahead'), ('Lunch', 12.5, 13.25, '#D9668F', 'ahead')],
}
HEAD = {'Mon': ('Mon', '2', '4 done'), 'Tue': ('Tue · Today', '3', '3 of 9 · 7 h 40'), 'Wed': ('Wed', '4', '3 planned'), 'Thu': ('Thu', '5', '4 planned')}
ICONKEY = {'Deep work': 'Deep work: roadmap', 'Weekly reset': 'Gym'}

def tm(t):
    h = int(t); m = int(round((t - h) * 60)); h12 = h if h <= 12 else h - 12
    return '%d:%02d' % (h12, m)

def card(n, a, b, col, st, x, w, selected=False):
    top = y(a); h = (b - a) * HOUR - 4
    if st == 'ghost':   # proposed by the ProposalSheet, not written until Add to day
        return ('<div aria-label="%s, %s to %s, proposed" style="position: absolute; left: %dpx; top: %dpx; width: %dpx; height: %dpx; box-sizing: border-box; border-radius: 16px; '
                'border: 2px dashed %s; background: rgba(17,97,92,.06); display: flex; align-items: center; gap: 10px; padding: 0 10px; z-index: 3; font-family: Manrope;">'
                '<span aria-hidden="true" style="width: 24px; height: 24px; border-radius: 50%%; flex: none; border: 2.5px dashed %s; box-sizing: border-box;"></span>'
                '<span style="font-size: 15px; font-weight: 700; color: %s; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">%s</span>'
                '<span style="margin-left: auto; font: 700 12px Manrope; color: %s; background: #E2EFEC; padding: 2px 8px; border-radius: 10px;">new</span></div>') % (n, tm(a), tm(b), x, top + 2, w, h, ACC, ACC, INK, n, '#0B4642')
    key = ICONKEY.get(n, n)
    done = st == 'done'
    if h < 56:   # short pill (under 35 min): one line, 15 px, dot 24 / 28
        dd = 28 if h >= 40 else 24
        if done: pst = 'background: %s; color: #fff;' % col
        elif st == 'cal': pst = 'background: %s; box-shadow: inset 0 0 0 2px #7A7280; color: #6A6273;' % GROUND
        elif st == 'now2': pst = 'background: radial-gradient(closest-side, %s calc(100%% - 4px), transparent calc(100%% - 3.5px)), conic-gradient(%s 0 40%%, %s33 40%% 100%%); color: %s;' % (SURF, col, col, col)
        else: pst = 'background: %s; box-shadow: inset 0 0 0 2.5px %s; color: %s;' % (SURF, col, col)
        d = '<span class="dot" style="left: 8px; top: %dpx; width: %dpx; height: %dpx; %s">%s</span>' % (
            (h - dd) / 2, dd, dd, pst,
            '<svg class="i" width="14" height="14" viewBox="0 0 24 24" aria-hidden="true">%s</svg>' % _ICON.get(key, ''))
        txt = '<span style="position: absolute; left: %dpx; right: 8px; top: 0; line-height: %dpx; font-size: 15px; font-weight: 700; color: %s; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">%s</span>' % (dd + 16, h, SEC if done else INK, n)
        lift = ' box-shadow: 0 0 0 1px rgba(36,31,43,.10), 0 4px 12px rgba(36,31,43,.12); z-index: 4;' if st == 'now2' else ''
        return ('<button class="blk" aria-label="%s, %s to %s%s" style="left: %dpx; top: %dpx; width: %dpx; height: %dpx; border-radius: %dpx;%s">%s%s</button>'
                % (n, tm(a), tm(b), ', done' if done else '', x, top + 2, w, h, min(h / 2, 16), lift, d, txt))
    ds = 45 if st == 'now' else 36
    if done: dst = 'background: %s; color: #fff;' % col
    elif st in ('now', 'now2'):
        p = 85 if st == 'now' else 40
        dst = 'background: radial-gradient(closest-side, %s calc(100%% - 5px), transparent calc(100%% - 4.5px)), conic-gradient(%s 0 %d%%, %s33 %d%% 100%%); color: %s;' % (SURF, col, p, col, p, col)
    elif st == 'cal': dst = 'background: %s; box-shadow: inset 0 0 0 2.5px #7A7280; color: #6A6273;' % GROUND
    else: dst = 'background: %s; box-shadow: inset 0 0 0 3.5px %s; color: %s;' % (SURF, col, col)
    ic_ = 22 if ds == 45 else 20
    dot_ = '<span class="dot" style="left: 6px; top: 6px; width: %dpx; height: %dpx; %s"><svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true">%s</svg></span>' % (ds, ds, dst, ic_, ic_, _ICON.get(key, ''))
    sub = ('<span class="num" style="display: block; font-size: 13px; font-weight: 700; color: %s;">Now, 18 min left</span>' % ACC) if st == 'now' else ''
    timeline = '2:00 · Calendar' if st == 'cal' else '%s–%s' % (tm(a), tm(b))
    txt = ('<span style="position: absolute; left: %dpx; top: 7px; right: 8px; line-height: 1.25;"><span style="display: block; font-size: 17px; font-weight: 700; color: %s;">%s</span>'
           '<span class="num" style="display: block; font-size: 13px; color: %s;">%s</span>%s</span>') % (ds + 14, SEC if done else INK, n, SEC, timeline, sub)
    sel = ' box-shadow: 0 0 0 2.5px %s; z-index: 2;' % ACC if selected else ''
    if st == 'now2': sel = ' box-shadow: 0 0 0 1px rgba(36,31,43,.10), 0 4px 12px rgba(36,31,43,.12); z-index: 4;'
    return ('<button class="blk" aria-label="%s, %s to %s%s"%s style="left: %dpx; top: %dpx; width: %dpx; height: %dpx;%s">%s%s</button>'
            % (n, tm(a), tm(b), ', done' if done else (', now, 18 minutes left, selected' if selected else ''), ' aria-pressed="true"' if selected else '', x, top + 2, w, h, sel, dot_, txt))

def grid(days, width, height):
    gut = 56; cw = (width - gut) // len(days)
    head_h = 60; body_h = height - head_h
    hs = []
    for i, d in enumerate(days):
        lab, num, meta = HEAD[d]; today = d == 'Tue'
        badge = ('<span style="width: 30px; height: 30px; border-radius: 50%%; background: %s; color: #FFFFFF; font-size: 16px; font-weight: 800; display: inline-flex; align-items: center; justify-content: center;">%s</span>' % (ACC, num)) if today else '<span style="font-size: 20px; font-weight: 800;">%s</span>' % num
        hs.append('<div role="columnheader"%s style="position: absolute; left: %dpx; width: %dpx; top: 0; height: %dpx; box-sizing: border-box; padding: 8px 12px; %s">'
                  '<div style="font-size: 13px; font-weight: 700; color: %s;">%s</div><div style="display: flex; align-items: center; gap: 8px; margin-top: 2px;">%s<span class="num" style="font-size: 13px; font-weight: 700; color: %s;">%s</span></div></div>' % (
                      ' aria-current="date"' if today else '', gut + i * cw, cw, head_h, 'background: rgba(17,97,92,.05);' if today else '', '#0B4642' if today else SEC, lab, badge, '#4E4757' if today else SEC, meta))
    lines = []
    for hh in range(8, 16):
        yy = head_h + y(hh)
        lines.append('<div style="position: absolute; left: %dpx; right: 0; top: %dpx; height: 1px; background: rgba(36,31,43,.06);"></div>' % (gut, yy))
        lab = '%d %s' % (hh if hh <= 12 else hh - 12, 'AM' if hh < 12 else 'PM')
        lines.append('<span class="num" style="position: absolute; left: 0; width: %dpx; text-align: right; top: %dpx; font-size: 13px; color: %s;">%s</span>' % (gut - 8, yy - 9, SEC, lab))
    for i in range(len(days) + 1):
        lines.append('<div style="position: absolute; left: %dpx; top: %dpx; bottom: 0; width: 1px; background: rgba(36,31,43,.07);"></div>' % (gut + i * cw, head_h))
    ti = days.index('Tue') if 'Tue' in days else None
    if ti is not None:
        lines.append('<div style="position: absolute; left: %dpx; top: %dpx; width: %dpx; bottom: 0; background: rgba(17,97,92,.035);"></div>' % (gut + ti * cw, head_h, cw))
    threads, cards = [], []
    for i, d in enumerate(days):
        x0 = gut + i * cw; tx = x0 + 6 + 6 + 18 - 2
        threads.append('<span style="position: absolute; left: %dpx; top: %dpx; bottom: 0; width: 0; border-left: 4px dotted #BEB6C7;"></span>' % (tx, head_h))
        for n, a, b, col, st in WEEK[d]:
            if st in ('done', 'now') and d in ('Mon', 'Tue'):
                end = min(b, 10.7) if d == 'Tue' else b
                threads.append('<span style="position: absolute; left: %dpx; top: %dpx; height: %dpx; width: 4px; background: %s;"></span>' % (tx, head_h + y(a), (end - a) * HOUR, col))
            if n == 'Call with Sam':
                cards.append(card(n, a, b, col, st, x0 + cw - 6 - int(cw * 0.78), int(cw * 0.78)).replace('top: %dpx' % (y(a) + 2), 'top: %dpx' % (head_h + y(a) + 2)))
                continue
            w = cw - 12
            c = card(n, a, b, col, st, x0 + 6, w, selected=(n == 'Deep work: roadmap'))
            cards.append(c.replace('top: %dpx' % (y(a) + 2), 'top: %dpx' % (head_h + y(a) + 2), 1))
    now = head_h + y(10.7)
    nowl = ('<div aria-label="Now, 10:42" style="position: absolute; left: %dpx; top: %dpx; width: %dpx; height: 2px; background: %s; z-index: 3;"></div>'
            '<span class="num" style="position: absolute; left: 2px; top: %dpx; font: 700 13px Manrope; color: %s; padding: 0 5px; border-radius: 9px; background: %s; border: 1px solid rgba(17,97,92,.3); z-index: 3;">10:42</span>') % (
                gut + (ti or 0) * cw, now - 1, cw, ACC, now - 10, ACC, SURF)
    return ('<div role="grid" aria-label="Week of 2 November, %s visible" style="position: relative; width: %dpx; height: %dpx; overflow: hidden; background: #EFE7DB; %s">'
            '%s<div aria-hidden="true">%s</div><div aria-hidden="true">%s</div>%s%s</div>') % (
                ' to '.join([days[0], days[-1]]), width, height, F_UI, ''.join(hs), ''.join(lines), ''.join(threads), ''.join(cards), nowl)

def plan_panel(width, height):
    def item(t, meta, ring='#8A8494'):
        return ('<div role="listitem" style="display: flex; align-items: center; gap: 12px; min-height: 56px; padding: 0 8px 0 4px; border-radius: 16px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.06);">'
                '<span aria-hidden="true" style="width: 36px; height: 36px; border-radius: 50%%; flex: none; box-shadow: inset 0 0 0 3px %s;"></span>'
                '<span style="line-height: 1.25; min-width: 0;"><span style="display: block; font-size: 17px; font-weight: 700;">%s</span><span class="num" style="display: block; font-size: 13px; color: %s;">%s</span></span></div>') % (SURF, ring, t, SEC, meta)
    def head(t, right=''):
        return ('<div style="display: flex; align-items: center; justify-content: space-between; height: 36px; margin-top: 6px;"><span style="display: flex; align-items: center; gap: 6px; font-size: 15px; font-weight: 700;">%s%s</span>'
                '<span style="font-size: 13px; color: %s;">%s</span></div>') % (ic('chev', 16, 2.4), t, SEC, right)
    return ('<aside aria-label="Plan" style="width: %dpx; height: %dpx; box-sizing: border-box; padding: 12px 14px; background: #F6F1EA; box-shadow: inset -1px 0 0 rgba(36,31,43,.08); overflow: hidden; %s color: %s;">'
            '<div style="height: 48px; border-radius: 24px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.12); display: flex; align-items: center; gap: 8px; padding: 0 14px; font-size: 17px; color: %s;">%sCapture a task</div>'
            '<div style="font-size: 13px; line-height: 18px; color: %s; margin: 8px 4px 0;">With a time it lands on the grid; without, it waits here. Paste a list for several.</div>'
            '%s<div role="list" style="display: flex; flex-direction: column; gap: 8px;">%s%s%s</div>'
            '%s<div role="list" style="display: flex; flex-direction: column; gap: 8px;">%s%s</div>'
            '%s<div style="height: 52px; border-radius: 16px; background: %s; box-shadow: 0 0 0 1px rgba(36,31,43,.10);"></div>'
            '<div style="display: flex; align-items: center; justify-content: space-between; margin-top: 8px;"><span style="font-size: 13px; line-height: 17px; color: %s; padding-right: 8px;">Nothing is added until you accept</span>'
            '<button style="height: 44px; padding: 0 16px; border: 0; border-radius: 22px; background: %s; color: #fff; font: 700 15px Manrope; white-space: nowrap; flex: none;">Plan it</button></div></aside>') % (
                width, height, F_UI, INK, SURF, SEC, ic('plus', 18, 2.4), SEC,
                head('Inbox', '3'), item('Buy a birthday gift', '30 min'), item('Book the car service', '30 min'), item('Call Mum tomorrow 3pm', '20 min'),
                head('Routines', 'drag onto a day'), item('Morning routine', '4 steps · 40 min', '#E2725B'), item('Weekly reset', '6 steps · 1 h 30', '#8B5CF6'),
                head('Brain dump'), SURF, SEC, ACC)

def toolbar(width, android):
    f = 'Roboto, system-ui, sans-serif' if android else '-apple-system, system-ui, sans-serif'
    pill = 'height: 44px; border: 0; border-radius: 22px; background: #ECE5DC; display: flex; align-items: center; justify-content: center; font: 600 15px %s; color: %s;' % (f, INK)
    seg = ''.join('<button role="tab"%s style="height: 36px; padding: 0 14px; border: 0; border-radius: 18px; font: 600 15px %s; %s">%s</button>' % (
        ' aria-selected="true"' if v == 'Week' else '', f, ('background: %s; color: %s; box-shadow: 0 1px 3px rgba(36,31,43,.12);' % (SURF, ACC)) if v == 'Week' else 'background: transparent; color: #4E4757;', v) for v in ('Day', '3 days', 'Week', 'Month'))
    return ('<div role="toolbar" aria-label="Plan" style="width: %dpx; height: 60px; box-sizing: border-box; display: flex; align-items: center; gap: 10px; padding: 0 14px; background: #F6F1EA; box-shadow: 0 1px 0 rgba(36,31,43,.08);">'
            '<button aria-label="Hide Plan panel" style="width: 44px; %s">%s</button>'
            '<span style="display: flex; border-radius: 22px; background: #ECE5DC;"><button aria-label="Previous week" style="width: 44px; %s background: transparent;">‹</button><button aria-label="Next week" style="width: 44px; %s background: transparent;">›</button></span>'
            '<button style="padding: 0 16px; %s">Today</button>'
            '<button aria-label="2 to 8 November 2026, choose a date" style="padding: 0 10px; %s background: transparent; font-weight: 700; font-size: 17px;">2–8 Nov 2026</button>'
            '<span style="flex: 1;"></span>'
            '<div role="tablist" aria-label="Canvas range" style="display: flex; gap: 2px; padding: 4px; border-radius: 22px; background: #ECE5DC;">%s</div>'
            '<button aria-haspopup="menu" aria-label="Day menu" style="padding: 0 12px 0 16px; gap: 4px; %s">Day%s</button>'
            '<button aria-label="New task" aria-haspopup="menu" style="width: 44px; height: 44px; border: 0; border-radius: 22px; background: %s; color: #fff; display: flex; align-items: center; justify-content: center;">%s</button></div>') % (
                width, pill, ic('sidebar', 20), pill, pill, pill, pill, seg, pill, ic('chev', 16, 2.4), ACC, ic('plus', 22, 2.4))

def workspace(w, h, days, android):
    tb = toolbar(w, android); body_h = h - 60
    return ('<div style="position: absolute; left: 216px; top: %dpx; width: %dpx; height: %dpx; display: flex; flex-direction: column; background: %s;">%s'
            '<div style="display: flex;">%s%s</div></div>') % (28 if android else 24, w, h, GROUND, tb, plan_panel(240, body_h), grid(days, w - 240, body_h))

def toolbar_narrow(width, android):
    """Narrow toolbar: the range tabs become a pop-up button (text-fits rule, ED-183)."""
    f = 'Roboto, system-ui, sans-serif' if android else '-apple-system, system-ui, sans-serif'
    pill = 'height: 44px; border: 0; border-radius: 22px; background: #ECE5DC; display: flex; align-items: center; justify-content: center; font: 600 15px %s; color: %s;' % (f, INK)
    return ('<div role="toolbar" aria-label="Plan" style="width: %dpx; height: 60px; box-sizing: border-box; display: flex; align-items: center; gap: 10px; padding: 0 14px; background: #F6F1EA; box-shadow: 0 1px 0 rgba(36,31,43,.08);">'
            '<button aria-label="Show Plan panel" style="width: 44px; %s">%s</button>'
            '<button style="padding: 0 16px; %s">Today</button>'
            '<button style="padding: 0 10px; %s background: transparent; font-weight: 700; font-size: 17px;">2–8 Nov</button><span style="flex: 1;"></span>'
            '<button aria-haspopup="menu" aria-label="Canvas range: Week" style="padding: 0 12px 0 16px; gap: 4px; %s">Week%s</button></div>') % (width, pill, ic('sidebar', 20), pill, pill, pill, ic('chev', 16, 2.4))

def workspace_inline(w, h, days, android, panel_w):
    """Workspace with an inline side panel: the grid narrows; the Plan panel steps aside (fewer than 3 days fit, ED-184)."""
    body_h = h - 60; gw = w - panel_w
    return ('<div style="position: absolute; left: 216px; top: %dpx; width: %dpx; height: %dpx; display: flex; flex-direction: column; background: %s;">%s'
            '<div style="display: flex;">%s</div></div>') % (28 if android else 24, gw, h, GROUND, toolbar_narrow(gw, android), grid(days, gw, body_h))
