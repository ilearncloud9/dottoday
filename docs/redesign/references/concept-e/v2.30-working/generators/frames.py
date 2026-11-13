"""R2-1 frames (light). Run: python3 -I build.py <height>."""
import re, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from parts import *

def touch(f):
    """Touch screens show no keyboard hints or pointer-only chrome (hardware-keyboard overlay is stage 2)."""
    f = re.sub(r'<kbd[^>]*>[^<]*</kbd>', '', f)
    return no_ctx_menu(no_cursor(f))

def status(android, w):
    if android:
        return ('<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: 28px; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; '
                'font: 500 13px Roboto, system-ui, sans-serif; color: %s; z-index: 30;"><span>10:42</span><span>▾ ▴ 100%%</span></div>'
                '<div aria-hidden="true" style="position: absolute; left: 50%%; bottom: 8px; width: 120px; margin-left: -60px; height: 4px; border-radius: 2px; background: %s; z-index: 30;"></div>') % (INK, INK)
    return ('<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: 24px; display: flex; align-items: center; justify-content: space-between; padding: 0 22px; '
            'font: 600 13px -apple-system, system-ui, sans-serif; color: %s; z-index: 30;"><span>10:42 Tue 3 Nov</span><span>100 %%</span></div>'
            '<div aria-hidden="true" style="position: absolute; left: 50%%; bottom: 8px; width: 160px; margin-left: -80px; height: 5px; border-radius: 3px; background: %s; z-index: 30;"></div>') % (INK, INK)

def device(w, h, inner, android):
    r = 22 if android else 30
    return ('<div style="position: relative; width: %dpx; height: %dpx; border-radius: %dpx; background: %s; overflow: hidden; '
            'box-shadow: 0 0 0 1px rgba(36,31,43,.2), 0 0 0 12px #241F2B, 0 0 0 13px rgba(36,31,43,.35); font-family: Manrope, system-ui, sans-serif; color: %s;">%s%s</div>'
            % (w, h, r, GROUND, INK, status(android, w), inner))

# ---------- medium Full Today (thread pane at the ED-256 touch scale)
DAY = [('Morning run', '6:45–7:30 AM', '#E2725B', 'done'), ('Coffee and plan the day', '7:30–7:45 AM', '#D9A23A', 'done'),
       ('Team standup', '8:00–8:15 AM', '#4A9BD6', 'done'), ('Deep work: roadmap', '9:00–11:00 AM', '#5B5FD6', 'now'),
       ('Call with Sam', '10:30–11:00 AM', '#2A9D8F', 'now2'), ('Lunch', '12:30–1:15 PM', '#D9668F', 'ahead'),
       ('Dentist', '2:00–2:30 PM · Calendar', '#7A7280', 'cal'), ('Pick up parcel', '3:00–3:45 PM', '#469763', 'ahead'),
       ('Gym', '6:00–7:00 PM', '#8B5CF6', 'ahead'), ('Read', '9:30–10:00 PM', '#8C6A4F', 'ahead')]

import json as _json
_ICON = _json.load(open(S1 + 'w143/icons.json'))
_ICON['Read'] = '<path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H20v15H6.5A2.5 2.5 0 0 0 4 20.5zM4 20.5A2.5 2.5 0 0 0 6.5 23H20"></path>'
_ICON['Coffee and plan the day'] = _ICON['Coffee & plan the day']

def dotc(col, st, d, name=None):
    """Task dot with its icon, as on the approved thread (E-Phones)."""
    ics = 22 if d >= 45 else 18
    svg = ('<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true">%s</svg>' % (ics, ics, _ICON[name])) if name in _ICON else ''
    if st == 'done': s = 'background: %s; color: #fff;' % col
    elif st in ('now', 'now2'):
        p = 85 if st == 'now' else 40
        s = 'background: radial-gradient(closest-side, %s calc(100%% - 5px), transparent calc(100%% - 4.5px)), conic-gradient(%s 0 %d%%, %s33 %d%% 100%%); color: %s;' % (SURF, col, p, col, p, col)
    elif st == 'cal': s = 'background: %s; box-shadow: inset 0 0 0 2.5px #7A7280; color: #6A6273;' % GROUND
    else: s = 'background: %s; box-shadow: inset 0 0 0 3.5px %s; color: %s;' % (SURF, col, col)
    return ('<span style="width: 48px; display: flex; justify-content: center; flex: none;"><span aria-hidden="true" style="width: %dpx; height: %dpx; border-radius: 50%%; '
            'display: flex; align-items: center; justify-content: center; %s">%s</span></span>') % (d, d, s, svg)

def today_pane(width):
    dots = ''.join('<span style="position: absolute; left: %dpx; top: 4px; width: 28px; height: 28px; border-radius: 50%%; background: %s; box-shadow: 0 0 0 2px %s;"></span>' % (i * 13, c, GROUND)
                   for i, c in enumerate(('#E2725B', '#D9A23A', '#4A9BD6')))
    rows = ['<div role="listitem" style="display: flex; align-items: center; gap: 12px; height: 52px; padding: 0 8px;">'
            '<span aria-hidden="true" style="position: relative; width: 54px; height: 36px; flex: none; margin-left: 2px;">%s</span>'
            '<span style="flex: 1; font: 700 16px Manrope; color: %s;">Earlier</span>'
            '<button aria-expanded="false" aria-label="Earlier, done tasks. Show" style="height: 44px; border: 0; background: transparent; font: 700 15px Manrope; color: %s;">Show ›</button></div>' % (dots, SEC, ACC)]
    for n, t, c, st in DAY:
        if st == 'done': continue
        now = st == 'now'
        card = 'background: %s; border-radius: 20px; box-shadow: 0 0 0 1px rgba(36,31,43,.06); min-height: 84px;' % SURF if now else 'min-height: 60px;'
        sub = '<div class="num" style="font-size: 14px; font-weight: 700; color: %s;">Now, 18 min left</div>' % ACC if now else ''
        rows.append('<div role="listitem" style="display: flex; align-items: center; gap: 12px; padding: 4px 8px; %s">%s<div style="flex: 1; min-width: 0; line-height: 1.25;">'
                    '<div class="num" style="font-size: 13px; color: %s;">%s</div><div style="font-size: %dpx; font-weight: 700;">%s</div>%s</div>'
                    '<button aria-label="Mark %s done" style="width: 44px; height: 44px; border: 0; background: transparent; display: flex; align-items: center; justify-content: center;">'
                    '<span style="width: 24px; height: 24px; border-radius: 50%%; box-shadow: inset 0 0 0 2px %s;"></span></button></div>' % (
                        card, dotc(c, st, 45 if now else 36, n), SEC, t, 19 if now else 17, n, sub, n, c if now else '#8A8494'))
        if n == 'Call with Sam':
            rows.append('<div aria-label="Now, 10:42" style="display: flex; align-items: center; gap: 10px; height: 26px; padding-left: 25px;">'
                        '<span style="width: 14px; height: 14px; border-radius: 50%%; background: %s; border: 2px solid #fff; box-sizing: border-box;"></span>'
                        '<span class="num" style="font: 700 13px Manrope; color: %s; padding: 0 6px; border-radius: 9px; border: 1px solid rgba(17,97,92,.3); background: %s;">10:42</span>'
                        '<span style="flex: 1; height: 1px; background: rgba(17,97,92,.28);"></span></div>' % (ACC, ACC, SURF))
    rows.append('<div style="display: flex; align-items: center; gap: 12px; height: 48px; padding: 0 8px; color: %s; font-size: 14px;">'
                '<span style="width: 48px; display: flex; justify-content: center; flex: none;"><span aria-hidden="true" style="width: 34px; height: 34px; border-radius: 50%%; background: #E6E3F7;"></span></span>Wind Down · 11:00 PM</div>' % SEC)
    wk = ''.join('<span style="width: 44px; height: 52px; border-radius: 16px; display: flex; flex-direction: column; align-items: center; justify-content: center; font: 600 13px Manrope; %s">%s<b style="font-size: 17px;">%d</b></span>' % (
        'background: %s; color: #fff;' % ACC if d == 3 else 'color: %s;' % SEC, w, d) for w, d in zip('MTWTFSS', range(2, 9)))
    return ('<div style="width: %dpx; font-family: Manrope, system-ui, sans-serif; color: %s;">'
            '<div style="font: 700 34px/40px Manrope;">Tue 3 Nov</div><div style="font: 700 15px Manrope; color: %s; margin-top: 4px;">3 of 9 done · 7 h 40 planned</div>'
            '<div style="display: flex; justify-content: space-between; margin: 16px 0 12px;">%s</div>'
            '<div role="list" aria-label="Tuesday timeline" style="position: relative; display: flex; flex-direction: column; gap: 4px;">'
            '<span aria-hidden="true" style="position: absolute; left: 30px; top: 24px; bottom: 24px; border-left: 4px dotted #BEB6C7;"></span>%s</div></div>') % (width, INK, SEC, wk, ''.join(rows))

# ---------- Minimal stacked (Now above the Day list) for portrait medium
MIN1160 = touch(phone(raw('Minimal · 1160 × 800')))

def minimal_stack(width, left, top, now_h):
    f = MIN1160
    a, b = section(f, 'Now'); now = f[a:b]
    now = re.sub(r'position: absolute; left: 200px; top: 52px; width: 670px; bottom: 0; padding: 22px 45px 0;', 'position: absolute; left: %dpx; top: %dpx; width: %dpx; height: %dpx; padding: 8px %dpx 0;' % (left, top, width, now_h, (width - 580) // 2), now, count=1)
    now = re.sub(r'box-shadow: inset -1px 0 0 rgba\(36,31,43,\.08\);', '', now, count=1)
    hb = re.search(r'<button aria-expanded="true" aria-label="Hide the Day column[^>]*>.*?</button>', now, re.S)
    if hb: now = now[:hb.start()] + now[hb.end():]
    a, b = section(f, 'Day'); day = f[a:b]
    day = re.sub(r'position: absolute; left: 870px; top: 52px; width: 290px; bottom: 0; padding: 12px 10px 0 6px;', 'position: absolute; left: %dpx; top: %dpx; width: %dpx; bottom: 0; padding: 12px 10px 0 6px; overflow: hidden; border-top: 1px solid rgba(36,31,43,.08);' % (left, top + now_h, width), day, count=1)
    day = re.sub(r'<button aria-label="Hide the Day column[^>]*>.*?</button>', '', day, count=1, flags=re.S)
    day = re.sub(r'<div style="padding: 0 6px 10px 10px;[^"]*">Click a task[^<]*</div>', '', day, count=1)
    return now + day
