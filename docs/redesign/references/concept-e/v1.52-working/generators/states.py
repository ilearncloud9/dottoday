"""G4-7 shared state and accessibility kit (owner approved option A, 2026-11-08). Review board only: E-G4-7-States.
Every frame is drawn in light from the approved boards and converted to dark with the final Stage 3 map. Copy comes from app_en.arb
where the app already has it (read-only audit, 2026-11-08); anything new is marked proposed."""
import re, sys
sys.path.insert(0, 'h')
from bal import elem
import darkify as DK
import stage3 as S3

PH = open('iPhone_Today.html').read()
AN = open('Android_Today.html').read()
FA = open('src96/project/E-FullA-v2.dc.html').read()
W = [m.start() for m in re.finditer(r'<div style="position: relative; width: 1280px; height: 800px;', FA)]
MAC = FA[W[0]:elem(FA, W[0])]
WEB = FA[W[1]:elem(FA, W[1])]
EP = open('src96/project/E-Phones.dc.html').read()
_i = EP.index('aria-label="iPhone Empty day"'); _d = EP.index('<div style="position: relative; width: 390px', _i)
EMPTY = EP[_d:elem(EP, _d)]

def rep(s, marker, new, back='<'):
    i = s.index(marker); a = s.rfind(back, 0, i + 1) if not s.startswith(back, i) else i
    return s[:a] + new + s[elem(s, a):]

def inner(s, marker, new):
    i = s.index(marker); a = s.rfind('<', 0, i + 1); e = elem(s, a); o = s.index('>', a) + 1
    return s[:o] + new + s[e - 6:] if False else s[:o] + new + s[e - len('</div>'):]

def ico(d, size=18, extra=''):
    return f'<svg class="i" width="{size}" height="{size}" viewBox="0 0 24 24" aria-hidden="true"{extra}>{d}</svg>'
I_SYNC = '<path d="M20 11a8 8 0 00-14.3-4.9L4 8M4 3.5V8h4.5M4 13a8 8 0 0014.3 4.9L20 16M20 20.5V16h-4.5"></path>'
I_OFF = '<path d="M3 3l18 18"></path><path d="M8.5 6.2A6 6 0 0117.7 10H18a4 4 0 012.6 7"></path><path d="M16 19H7a4.5 4.5 0 01-1.8-8.6"></path>'
I_CHECK = '<circle cx="12" cy="12" r="8.5"></circle><path d="M8.5 12.2l2.4 2.4 4.6-5"></path>'
I_WAIT = '<circle cx="12" cy="12" r="8.5"></circle><path d="M12 7.5V12l3 2"></path>'
I_ALERT = '<path d="M12 4l9 16H3z"></path><path d="M12 10v4M12 17v.01"></path>'
I_TWO = '<rect x="3" y="5" width="8" height="12" rx="2"></rect><rect x="13" y="7" width="8" height="12" rx="2"></rect>'
I_DEVICE = '<rect x="7" y="3" width="10" height="18" rx="2.5"></rect><path d="M11 18h2"></path>'
I_LOCK = '<rect x="5" y="10" width="14" height="10" rx="2"></rect><path d="M8 10V7a4 4 0 018 0v3"></path>'
I_CLOCK = '<circle cx="12" cy="12" r="8.5"></circle><path d="M12 7v5h4"></path>'
I_INBOX = '<path d="M4 13l2.5-7h11L20 13v5H4z"></path><path d="M4 13h4.5l1 2h5l1-2H20"></path>'
I_TAB = '<rect x="3" y="5" width="18" height="14" rx="2"></rect><path d="M3 9h18M8 5v4"></path>'

def sync_btn(kind, android=False):
    """Header sync button; the state is carried by the icon and badge shape plus the accessible name, never colour alone."""
    sz = 48 if android else 44
    col = '#4E4757' if android else '#6A6273'
    icon, badge, label = I_SYNC, '', 'Synced'
    if kind == 'synced':
        badge = '<span aria-hidden="true" style="position: absolute; right: 10px; bottom: 11px; width: 8px; height: 8px; border-radius: 50%; background: #11615C; border: 2px solid #FBF7F1;"></span>'
    elif kind == 'syncing':
        label = 'Syncing'; badge = '<span aria-hidden="true" style="position: absolute; inset: 7px; border-radius: 50%; border: 2px solid rgba(17,97,92,.18); border-top-color: #11615C;"></span>'
    elif kind == 'offline':
        icon, label = I_OFF, 'Offline, changes saved here'
    elif kind == 'waiting':
        label = '3 changes waiting to sync'; badge = '<span aria-hidden="true" style="position: absolute; right: 3px; top: 5px; min-width: 18px; height: 18px; padding: 0 4px; box-sizing: border-box; border-radius: 9px; background: #241F2B; color: #FFFFFF; font: 700 11px/18px Manrope, system-ui; text-align: center;">3</span>'
    elif kind == 'problem':
        label = 'Sync problem'; badge = '<span aria-hidden="true" style="position: absolute; right: 4px; top: 5px; width: 18px; height: 18px; border-radius: 9px; background: #241F2B; color: #FFFFFF; font: 800 12px/18px Manrope, system-ui; text-align: center;">!</span>'
    elif kind == 'conflict':
        icon, label = I_TWO, '1 change needs you'
        badge = '<span aria-hidden="true" style="position: absolute; right: 3px; top: 5px; min-width: 18px; height: 18px; border-radius: 9px; background: #241F2B; color: #FFFFFF; font: 700 11px/18px Manrope, system-ui; text-align: center;">1</span>'
    return (f'<button aria-label="{label}" style="position: relative; width: {sz}px; height: {sz}px; border: 0; border-radius: {sz//2}px; background: transparent; color: {col}; '
            f'display: flex; align-items: center; justify-content: center; padding: 0;">{ico(icon, 20)}{badge}</button>')

def set_sync(dev, kind, android=False):
    i = dev.index('<button aria-label="Synced"'); return dev[:i] + sync_btn(kind, android) + dev[elem(dev, i):]

def strip_slot(dev, android=False):
    marker = 'Long-press a dot to select several' if android else 'Hold a dot to select several tasks'
    i = dev.index(marker); a = dev.rfind('<div style="position: absolute; top:', 0, i); return a, elem(dev, a)

def banner(dev, icon, text, action=None, android=False, live='polite'):
    """The existing strip above the screen (sync_banner.dart), drawn in the tip's slot. Calm surface, icon + words, one action."""
    a, e = strip_slot(dev, android)
    top = 204 if android else 192
    act = (f'<button style="margin-left: auto; height: 32px; padding: 0 14px; border: 0; border-radius: 16px; background: #E2EFEC; color: #0B4642; font: 700 13px Manrope, system-ui;">{action}</button>' if action else '')
    b = (f'<div role="status" aria-live="{live}" style="position: absolute; top: {top}px; left: 16px; right: 16px; height: {44 if android else 40}px; border-radius: {18 if android else 20}px; background: #F6F1EA; '
         f'box-shadow: inset 0 0 0 1px rgba(36,31,43,.08); display: flex; align-items: center; gap: 8px; padding: 0 6px 0 14px; font: 600 13px Manrope, system-ui, sans-serif; color: #241F2B;">'
         f'<span style="display: flex; color: #4E4757;">{ico(icon, 17)}</span><span>{text}</span>{act}</div>')
    return dev[:a] + b + dev[e:]

def no_strip(dev, android=False):
    a, e = strip_slot(dev, android); return dev[:a] + dev[e:]

def timeline(dev, html):
    i = dev.index('<div role="list" aria-label="Tuesday timeline"'); e = elem(dev, i); o = dev.index('>', i) + 1
    return dev[:o] + html + dev[e - 6:]

def summary(dev, html):
    i = dev.index('3 of 9 done · 7 h 40 planned'); a = dev.rfind('<div', 0, i); o = dev.index('>', a) + 1
    return dev[:o] + html + dev[elem(dev, a) - 6:]

def skeleton(n=7):
    rows = ''
    for k in range(n):
        w = [150, 120, 180, 110, 160, 130, 140][k % 7]
        rows += (f'<div style="position: relative; height: 54px; display: flex; align-items: center; padding: 0 20px; gap: 14px;">'
                 f'<span style="width: 34px; height: 34px; border-radius: 50%; background: #ECE5DC; flex: none;"></span>'
                 f'<span style="display: flex; flex-direction: column; gap: 7px;"><span style="width: 74px; height: 9px; border-radius: 5px; background: #ECE5DC;"></span>'
                 f'<span style="width: {w}px; height: 12px; border-radius: 6px; background: #ECE5DC;"></span></span></div>')
    return ('<div role="status" aria-label="Loading" aria-busy="true" style="position: relative; padding-top: 6px;">'
            '<span aria-hidden="true" style="position: absolute; left: 36px; top: 30px; bottom: 30px; border-left: 2px dotted #BEB6C7;"></span>' + rows + '</div>')

def centre(icon, title, body, actions='', extra=''):
    return (f'<div style="display: flex; flex-direction: column; align-items: center; text-align: center; gap: 10px; padding: 70px 34px 0; font-family: Manrope, system-ui, sans-serif;">'
            f'<span style="width: 56px; height: 56px; border-radius: 50%; background: #F6F1EA; color: #4E4757; display: flex; align-items: center; justify-content: center;">{ico(icon, 26)}</span>'
            f'<div style="font: 800 20px/26px Manrope, system-ui; color: #241F2B;">{title}</div><div style="font: 500 15px/21px Manrope, system-ui; color: #4E4757;">{body}</div>{extra}{actions}</div>')

def pbtn(t, kind='primary', w=None):
    st = {'primary': 'background: #11615C; color: #FFFFFF;', 'tonal': 'background: #E2EFEC; color: #0B4642;', 'plain': 'background: #FFFDF9; color: #241F2B; box-shadow: inset 0 0 0 1px rgba(36,31,43,.16);'}[kind]
    return f'<button style="min-height: 44px; {"width: " + str(w) + "px;" if w else ""} padding: 0 20px; border: 0; border-radius: 22px; {st} font: 700 15px Manrope, system-ui;">{t}</button>'

def sheet(dev, html, height=470, android=False):
    sc = '<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(36,31,43,.32); z-index: 40;"></div>'
    grab = '' if android else '<div aria-hidden="true" style="width: 36px; height: 5px; border-radius: 3px; background: #CFC6D6; margin: 6px auto 10px;"></div>'
    sh = (f'<div role="dialog" aria-modal="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: {height}px; z-index: 41; border-radius: {28 if android else 34}px {28 if android else 34}px 0 0; '
          f'background: #FFFDF9; box-shadow: 0 -8px 30px rgba(36,31,43,.16); padding: 6px 20px 34px; box-sizing: border-box; font-family: Manrope, system-ui, sans-serif; color: #241F2B; overflow: hidden;">{grab}{html}</div>')
    return dev[:-6] + sc + sh + dev[-6:]

def toast(dev, text, action=None, android=False, bottom=100):
    act = f'<button style="margin-left: auto; height: 36px; padding: 0 12px; border: 0; background: none; color: #A3E2D9; font: 700 14px Manrope, system-ui;">{action}</button>' if action else ''
    t = (f'<div role="status" aria-live="polite" style="position: absolute; left: 16px; right: 16px; bottom: {bottom}px; z-index: 30; min-height: 48px; border-radius: {8 if android else 16}px; background: #2E2836; '
         f'color: #FBF7F1; display: flex; align-items: center; gap: 10px; padding: 6px 6px 6px 16px; box-sizing: border-box; font: 600 14px/19px Manrope, system-ui;">{text}{act}</div>')
    return dev[:-6] + t + dev[-6:]

def conflict_card(field, mine, theirs, title='Deep work: roadmap'):
    return (f'<div style="border-radius: 20px; background: #F6F1EA; padding: 14px 16px; display: flex; flex-direction: column; gap: 8px;">'
            f'<div style="font: 800 16px Manrope, system-ui;">{title} · {field}</div>'
            f'<div style="display: flex; gap: 8px; align-items: baseline;"><span style="flex: none; width: 96px; font: 600 13px Manrope; color: #4E4757;">This device</span><span style="font: 700 15px Manrope;">{mine}</span></div>'
            f'<div style="display: flex; gap: 8px; align-items: baseline;"><span style="flex: none; width: 96px; font: 600 13px Manrope; color: #4E4757;">Other device</span><span style="font: 700 15px Manrope;">{theirs}</span><span style="margin-left: auto; font: 600 12px Manrope; color: #4E4757;">in use now</span></div>'
            f'<div style="display: flex; gap: 10px; margin-top: 4px;">{pbtn("Keep mine", "plain")}{pbtn("Keep theirs", "plain")}</div></div>')

def task_time(dev, old, new):
    return dev.replace(old, new, 1)

# ---------- phones ----------
def iph():
    f = {}
    d = set_sync(no_strip(PH), 'synced'); d = summary(d, '<span style="display: inline-block; width: 190px; height: 12px; border-radius: 6px; background: #ECE5DC;"></span>')
    f['A1'] = timeline(d, skeleton())
    d = set_sync(no_strip(PH), 'syncing'); d = summary(d, 'Bringing your tasks to this device…')
    prog = ('<div role="progressbar" aria-label="Bringing your tasks to this device" aria-valuenow="12" aria-valuemax="40" style="margin: 8px 20px 4px; display: flex; flex-direction: column; gap: 8px; font-family: Manrope;">'
            '<div style="height: 6px; border-radius: 3px; background: #ECE5DC; overflow: hidden;"><div style="width: 30%; height: 6px; background: #11615C;"></div></div>'
            '<div style="display: flex; justify-content: space-between; font: 600 13px Manrope; color: #4E4757;"><span>12 of 40</span><span>Tasks appear as they arrive</span></div></div>')
    tl = PH[PH.index('<div role="list" aria-label="Tuesday timeline"'):]
    first = re.findall(r'<div role="listitem"[\s\S]*?(?=<div role="listitem"|<div style="position: relative; height: 32px)', tl)[:3]
    f['A2'] = timeline(d, prog + ''.join(first) + skeleton(3))
    f['A3'] = set_sync(PH, 'syncing')
    f['A6'] = timeline(set_sync(no_strip(PH), 'synced'), centre(I_ALERT, "This didn't load", 'Your tasks are safe on this device.', pbtn('Try again', 'tonal')))
    f['B2'] = banner(set_sync(PH, 'offline'), I_OFF, 'Offline · everything still works here')
    d = set_sync(PH, 'problem')
    f['B4'] = sheet(d, '<div style="display: flex; align-items: center; justify-content: space-between;"><div style="font: 800 22px Manrope;">Sync</div><button style="height: 44px; padding: 0 6px; border: 0; background: none; color: #11615C; font: 700 16px -apple-system, system-ui;">Done</button></div>'
                    '<div role="status" style="margin-top: 10px; display: flex; gap: 10px; align-items: flex-start; font: 600 15px/21px Manrope;"><span style="color: #4E4757; display: flex; margin-top: 1px;">' + ico(I_ALERT, 20) + '</span>Couldn\'t sync. Your changes are safe here; it will try again.</div>'
                    '<div style="margin-top: 8px; font: 500 14px Manrope; color: #4E4757;">Last synced 12 min ago · 3 changes waiting to sync</div>'
                    '<div style="margin-top: 18px; display: flex; gap: 10px;">' + pbtn('Sync now', 'primary') + '</div>'
                    '<div style="margin-top: 18px; font: 500 13px/19px Manrope; color: #4E4757;">Sync now sends the same saved changes again. It can\'t create a second copy of a task.</div>', 360)
    # conflict journey
    old = '9:00–11:00 AM · Now, 18 min left'
    d = set_sync(PH, 'conflict'); d = d.replace(old, '9:30–11:30 AM · Now, 48 min left', 1) if old in d else d
    f['C1'] = banner(d, I_TWO, '1 change needs you', 'Review')
    f['C2'] = sheet(d, '<div style="display: flex; align-items: center; justify-content: space-between;"><div style="font: 800 22px Manrope;">Changed on two devices</div><button style="height: 44px; padding: 0 6px; border: 0; background: none; color: #11615C; font: 700 16px -apple-system, system-ui;">Done</button></div>'
                    '<div style="margin: 4px 0 14px; font: 500 14px/20px Manrope; color: #4E4757;">The other device\'s change is in use until you choose.</div>'
                    + conflict_card('Time', '9:00–11:00 AM', '9:30–11:30 AM'), 420)
    d2 = set_sync(PH, 'synced')
    f['C3'] = toast(d2, "Kept this device's time", 'Undo')
    # accessibility
    f['D3'] = voiceover(PH)
    f['D4'] = reduce_tx(PH)
    f['D1'] = big_text()
    return f

def voiceover(dev):
    ring = '<div aria-hidden="true" style="position: absolute; left: 6px; top: 452px; width: 378px; height: 92px; border-radius: 28px; box-shadow: 0 0 0 3px #241F2B, 0 0 0 5px #FFFDF9; z-index: 25;"></div>'
    cap = ('<div aria-hidden="true" style="position: absolute; left: 14px; right: 14px; top: 560px; z-index: 26; border-radius: 14px; background: #2E2836; color: #FBF7F1; padding: 10px 14px; font: 600 13px/18px -apple-system, system-ui;">'
           '"Deep work: roadmap. 9:00 to 11:00 AM. Now, 18 minutes left. 2 of 4 steps done. Actions available: Done, Focus, Need more time."</div>')
    return dev[:-6] + ring + cap + dev[-6:]

def reduce_tx(dev):
    d = re.sub(r'background: linear-gradient\(180deg, rgba\(255,255,255,0\.6\d\), rgba\(255,25\d,24\d,0\.\d+\)\); backdrop-filter: blur\([^;]*;', 'background: #FFFDF9; outline: 1.5px solid #6A6273;', dev)
    d = re.sub(r'<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 200px; background: linear-gradient[^"]*"></div>', '', d)
    d = d.replace('color: #6E6E73', 'color: #4E4757').replace('color: #6A6273', 'color: #4E4757')
    d = d.replace('border-left: 2px dotted #BEB6C7', 'border-left: 2px dotted #7A7280').replace('dotted #BEB6C7', 'dotted #7A7280')
    return d

def big_text():
    """iPhone Today at the largest accessibility size (about 200 %): one column, times above titles, nothing truncated, the bar keeps icons and labels move to the large-content viewer."""
    rows = [('6:45–7:30 AM', 'Morning run', '#DF6147', True), ('7:30–7:45 AM', 'Coffee &amp; plan the day', '#AF7E22', True), ('9:00–11:00 AM · Now, 18 min left', 'Deep work: roadmap', '#5B5FD6', False), ('10:30–11:00 AM', 'Call with Sam', '#289588', False)]
    h = ''
    for t, n, c, done in rows:
        dot = (f'<span style="width: 44px; height: 44px; border-radius: 50%; flex: none; background: {c}; color: #FFFFFF; display: flex; align-items: center; justify-content: center;">{ico("<path d=\"M6 12.5l4 4 8-9\"></path>", 22)}</span>' if done
               else f'<span style="width: 44px; height: 44px; border-radius: 50%; flex: none; background: #FFFDF9; box-shadow: inset 0 0 0 4px {c};"></span>')
        h += (f'<div role="listitem" style="display: flex; gap: 14px; align-items: flex-start; padding: 12px 20px;">{dot}<div><div class="num" style="font: 600 22px/28px -apple-system, system-ui; color: #4E4757;">{t}</div>'
              f'<div style="font: 700 34px/40px Manrope, system-ui; color: #241F2B;">{n}</div></div></div>')
    return ('<div style="position: relative; width: 390px; height: 844px; border-radius: 48px; background: #FBF7F1; overflow: hidden; box-shadow: 0 0 0 1px rgba(36,31,43,.10), 0 0 0 8px #241F2B, 0 0 0 9px rgba(36,31,43,.35); font-family: -apple-system, system-ui, sans-serif;">'
            '<div aria-hidden="true" style="position: absolute; top: 11px; left: 132px; width: 126px; height: 37px; border-radius: 25px; background: #000; z-index: 20;"></div>'
            '<div style="position: absolute; top: 56px; left: 20px; right: 20px; display: flex; align-items: center; justify-content: space-between;"><div style="font: 700 44px/50px -apple-system, system-ui; color: #241F2B;">Tue 3 Nov</div>' + sync_btn('synced') + '</div>'
            '<div class="num" style="position: absolute; top: 116px; left: 20px; right: 20px; font: 700 24px/30px Manrope; color: #4E4757;">3 of 9 done</div>'
            '<div role="list" style="position: absolute; top: 160px; left: 0; right: 0; bottom: 110px; overflow: hidden;">' + h + '</div>'
            '<nav aria-label="Main" style="position: absolute; left: 21px; right: 90px; bottom: 21px; height: 63px; border-radius: 31.5px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.12); display: grid; grid-template-columns: repeat(4,1fr); align-items: center; justify-items: center; color: #4E4757;">'
            + ''.join(f'<span style="display: flex; color: {"#0B4642" if k == 0 else "#4E4757"};">{ico(p, 28)}</span>' for k, p in enumerate(['<path d="M4 6h16M4 12h10M4 18h13"></path>', I_INBOX, '<rect x="3.5" y="5" width="17" height="15" rx="2"></rect><path d="M3.5 10h17M8 3v4M16 3v4"></path>', '<circle cx="11" cy="11" r="6.5"></circle><path d="M20 20l-4.5-4.5"></path>'])) +
            '</nav><button aria-label="Add a task" style="position: absolute; right: 21px; bottom: 21px; width: 63px; height: 63px; border: 0; border-radius: 50%; background: #11615C; color: #FFFFFF; display: flex; align-items: center; justify-content: center;">' + ico('<path d="M12 5v14M5 12h14"></path>', 30) + '</button>'
            '<div aria-hidden="true" style="position: absolute; bottom: 8px; left: 128px; width: 134px; height: 5px; border-radius: 3px; background: #241F2B;"></div></div>')

def inbox_empty():
    d = no_strip(PH)
    d = d.replace('>Tue 3 Nov<svg class="i" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true" style="color: #11615C; stroke-width: 2.6;"><path d="M6 9l6 6 6-6"></path></svg>', '>Inbox', 1)
    i = d.index('3 of 9 done · 7 h 40 planned'); a = d.rfind('<div', 0, i); d = d[:a] + d[elem(d, a):]
    i = d.index('<button aria-label="Monday 2 November"'); a = d.rfind('<div style="position: absolute; top: 128px', 0, i); d = d[:a] + d[elem(d, a):]
    d = timeline(d, '<div style="height: 1px;"></div>')
    d = d.replace('aria-label="Tuesday timeline" style="position: absolute; top: 242px;', 'aria-label="Inbox" style="position: absolute; top: 110px;')
    d = timeline(d.replace('aria-label="Inbox" style="position: absolute; top: 110px;', 'aria-label="Tuesday timeline" style="position: absolute; top: 110px;'),
                 centre(I_INBOX, 'Inbox is clear', 'Tasks without a time wait here. Tap + or paste a list to add several.', ''))
    # Inbox tab selected, badge gone
    n0 = d.index('<a href="#" aria-current="page"'); n1 = elem(d, n0); t = d[n0:n1]
    m0 = d.index('<a href="#" aria-label="Inbox, 3 items"'); m1 = elem(d, m0); ib = d[m0:m1]
    st_sel = re.search(r'style="([^"]*)"', t).group(1); st_un = re.search(r'style="([^"]*)"', ib).group(1)
    t2 = t.replace(f'style="{st_sel}"', f'style="{st_un}"').replace(' aria-current="page"', '')
    ib2 = re.sub(r'<span[^>]*>3</span>', '', ib.replace(f'style="{st_un}"', f'style="{st_sel}"').replace('aria-label="Inbox, 3 items"', 'aria-current="page" aria-label="Inbox, empty"'))
    d = d[:n0] + t2 + d[n1:m0] + ib2 + d[m1:]
    return d

# ---------- Android ----------
def andr():
    f = {}
    f['B3'] = banner(set_sync(AN, 'waiting', True), I_OFF, 'Offline · everything still works here', None, True)
    d = set_sync(AN, 'synced', True)
    f['A7'] = toast(d, "Couldn't save on this device. Try again.", 'Try again', True, 112)
    return f

# ---------- Mac / web ----------
def mac_footer(w, text, icon=I_CHECK):
    i = w.index('<div class="num" style="margin-top: auto; height: 44px;'); a = i; e = elem(w, a); o = w.index('>', a) + 1
    return w[:o] + f'<span style="display: flex; align-items: center; gap: 6px;"><span style="display: flex;">{ico(icon, 15)}</span>{text}</span>' + w[e - 6:]

def mac_popover(w, html, left=8, bottom=52, width=330):
    p = (f'<div role="dialog" aria-label="Sync" style="position: absolute; left: {left}px; bottom: {bottom}px; width: {width}px; z-index: 50; border-radius: 12px; background: #F8F5FA; '
         f'box-shadow: 0 0 0 .5px rgba(0,0,0,.25), 0 12px 34px rgba(36,31,43,.26); padding: 14px; font-family: -apple-system, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 10px;">{html}</div>')
    return w[:-6] + p + w[-6:]

def mac_banner(w, icon, text, action):
    """Mac and web: the same strip, as a bar under the toolbar."""
    i = w.index('role="toolbar" aria-label="Plan"'); a = w.rfind('<div', 0, i); e = elem(w, a)
    bar = (f'<div role="status" aria-live="polite" style="height: 40px; flex: none; display: flex; align-items: center; gap: 8px; padding: 0 8px 0 14px; background: #F6F1EA; box-shadow: 0 1px 0 rgba(36,31,43,.08); font: 600 13px Manrope, system-ui; color: #241F2B;">'
           f'<span style="display: flex; color: #4E4757;">{ico(icon, 16)}</span>{text}<button style="margin-left: auto; height: 28px; padding: 0 12px; border: 0; border-radius: 14px; background: #E2EFEC; color: #0B4642; font: 700 13px Manrope;">{action}</button></div>')
    return w[:e] + bar + w[e:]

def desk():
    f = {}
    w = mac_footer(MAC, '1 change needs you', I_TWO)
    card = conflict_card('Time', '9:00–11:00 AM', '9:30–11:30 AM').replace('min-height: 44px', 'min-height: 30px').replace('border-radius: 22px', 'border-radius: 7px')
    f['C4'] = mac_popover(w, '<div style="font: 700 13px -apple-system;">Changed on two devices</div><div style="font: 12px -apple-system; color: #4E4757;">The other device\'s change is in use until you choose.</div>' + card)
    w = mac_footer(MAC, 'Offline · changes saved here', I_OFF)
    f['B5'] = mac_popover(w, '<div style="font: 700 13px -apple-system;">Sync</div><div style="font: 13px/18px -apple-system;">Offline. Changes are saved here and sync when you\'re back.</div><div style="font: 12px -apple-system; color: #4E4757;">Last synced 10:42 · 2 changes waiting to sync</div>'
                          '<button disabled aria-disabled="true" style="align-self: flex-start; height: 26px; padding: 0 12px; border: 0; border-radius: 7px; background: #F1ECE4; color: #8A8494; font: 500 13px -apple-system;">Sync now</button>')
    f['A10'] = mac_banner(mac_footer(MAC, 'Sync paused', I_LOCK), I_LOCK, 'Your session has ended. Sign in again to keep syncing.', 'Sign in…')
    f['D2'] = focus_order(MAC)
    f['A8'] = web_page(WEB, I_TAB, 'Dottoday is open in another tab', 'To keep your tasks safe, only one tab can use them at a time.', 'Use it here')
    f['A9'] = web_page(WEB, I_OFF, "You're offline", 'Dottoday needs a connection the first time it opens on this browser. After that it works offline, and your tasks never leave this device unless you sign in.', 'Try again', shell=False)
    f['B6'] = web_footer(WEB)
    return f

def focus_order(w):
    pts = [(1, 100, 92, 'Sidebar'), (2, 250, 26, 'Toolbar'), (3, 316, 120, 'Plan panel'), (4, 700, 300, 'Week'), (5, 1150, 120, 'Inspector')]
    b = ''.join(f'<span aria-hidden="true" style="position: absolute; left: {x}px; top: {y}px; z-index: 60; height: 26px; padding: 0 9px; border-radius: 13px; background: #241F2B; color: #FFFFFF; font: 700 13px/26px Manrope; white-space: nowrap;">{n} · {t}</span>' for n, x, y, t in pts)
    ring = '<span aria-hidden="true" style="position: absolute; left: 226px; top: 56px; width: 176px; height: 40px; border-radius: 21px; box-shadow: 0 0 0 2px #FBF7F1, 0 0 0 5px #11615C; z-index: 59;"></span>'
    return w[:-6] + ring + b + w[-6:]

def web_page(w, icon, title, body, action, shell=True):
    """Web recovery page inside the browser chrome (address bar kept)."""
    i = w.index('<nav aria-label="Sidebar"'); a = w.rfind('<!-- sidebar', 0, i)
    page = (f'<div style="position: absolute; left: 0; right: 0; top: 52px; bottom: 0; background: #FBF7F1; display: flex; align-items: center; justify-content: center; font-family: Manrope, system-ui, sans-serif;">'
            f'<div role="alert" style="width: 440px; border-radius: 24px; background: #FFFDF9; box-shadow: inset 0 0 0 1px rgba(36,31,43,.08); padding: 32px; display: flex; flex-direction: column; align-items: center; gap: 12px; text-align: center;">'
            f'<span style="width: 56px; height: 56px; border-radius: 50%; background: #F6F1EA; color: #4E4757; display: flex; align-items: center; justify-content: center;">{ico(icon, 26)}</span>'
            f'<div style="font: 800 22px Manrope; color: #241F2B;">{title}</div><div style="font: 500 15px/22px Manrope; color: #4E4757;">{body}</div>{pbtn(action, "primary")}</div></div>')
    return w[:a] + page + '</div>'

def web_footer(w):
    w = w.replace('>Synced · 10:42</span>', '><span style="display: inline-flex; margin-right: 6px;">' + ico(I_DEVICE, 14) + '</span>Saved in this browser · 2 changes waiting to sync</span>', 1)
    return w

# ---------- assembly ----------
def dark(x):
    return S3.mac_selected(S3.extra(DK.darkify(S3.shadows(x)))).replace('background: none; color: #A3E2D9;', 'background: none; color: #0B4642;')

def pair(key, html, w, h, z, title, notes, tag='Proposal · G4-7 kit · not merged'):
    box = lambda x, bg, th, fg: f'<div {th} style="width:{int(w*z)+16}px;height:{int(h*z)+16}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{bg};color:{fg};overflow:hidden;flex:none"><div style="zoom:{z}">{x}</div></div>'
    lab = lambda t: f'<div style="font:700 13px Manrope;color:#6A6273;width:{int(w*z)+16}px">{t}</div>'
    cap = (f'<div style="font:500 14px/20px Manrope;color:#4E4757;width:{2*int(w*z)+44}px"><div style="font:800 17px Manrope;color:#241F2B">{key} · {title}</div>'
           + ''.join(f'<div>{n}</div>' for n in notes) + f'<span class="th" style="margin-top:6px">{tag}</span></div>')
    return (f'<section aria-label="{key} {title}" style="display:flex;flex-direction:column;gap:8px"><div style="display:flex;gap:12px">{lab("Light")}{lab("Dark · P1")}</div>'
            f'<div style="display:flex;gap:12px;align-items:flex-start">{box(html,"#E9E2D6","","#241F2B")}{box(dark(html),"#0E0C0E","data-theme=\"dark\"","#F3ECE4")}</div>{cap}</section>')

def specimen():
    """B1: the sync status vocabulary. Each state = icon shape + words (+ badge); colour is never the only signal."""
    rows = [
        (I_DEVICE, 'On this device', 'Signed out. Tasks stay on this device.', 'Sync sheet: "Sign in…"', 'none'),
        (I_CHECK, 'Synced · 4 min ago', 'Up to date with your other devices.', 'Header button dot; Mac/web sidebar line', 'none'),
        (I_SYNC, 'Syncing…', 'Sending and receiving changes. Tasks stay on screen.', 'Header button ring', 'none'),
        (I_OFF, 'Offline · changes saved here', 'No connection. Every change is saved on this device first.', 'Banner + header icon', 'polite, once'),
        (I_WAIT, '3 changes waiting to sync', 'Saved here; not yet on your other devices.', 'Header badge "3"; sheet line', 'none'),
        (I_ALERT, "Couldn't sync", 'Your changes are safe here; it will try again (5 s, doubling to 5 min).', 'Header badge "!"; sheet', 'polite'),
        (I_CLOCK, 'Sync paused', "This device's clock is fast; its changes wait until the clock is right.", 'Sheet line', 'polite'),
        (I_TWO, '1 change needs you', 'The same detail changed on two devices; the other device\'s change is in use until you choose.', 'Banner "Review" + header badge', 'polite'),
        (I_ALERT, "Couldn't save on this device", 'The change did not save. Try again; the draft stays open.', 'Snackbar / toast at the edit', 'assertive'),
        (I_LOCK, 'Session ended', 'Sign in again to keep syncing. Tasks stay on this device.', 'Banner "Sign in…"', 'polite'),
    ]
    tr = ''.join(f'<tr><td style="padding:9px 10px;border-bottom:1px solid rgba(36,31,43,.08)"><span style="display:inline-flex;align-items:center;gap:8px;font:700 15px Manrope;color:#241F2B"><span style="display:flex;color:#4E4757">{ico(i, 18)}</span>{a}</span></td>'
                 f'<td style="padding:9px 10px;border-bottom:1px solid rgba(36,31,43,.08);font:500 14px/19px Manrope;color:#4E4757">{b}</td><td style="padding:9px 10px;border-bottom:1px solid rgba(36,31,43,.08);font:500 13px Manrope;color:#4E4757">{c}</td>'
                 f'<td style="padding:9px 10px;border-bottom:1px solid rgba(36,31,43,.08);font:600 13px Manrope;color:#4E4757">{d}</td></tr>' for i, a, b, c, d in rows)
    return ('<div style="width:1100px;border-radius:20px;background:#FFFDF9;box-shadow:inset 0 0 0 1px rgba(36,31,43,.08);padding:18px 18px 8px;font-family:Manrope">'
            '<table style="border-collapse:collapse;width:100%"><thead><tr>' + ''.join(f'<th style="text-align:left;padding:6px 10px;font:700 12px Manrope;color:#6A6273">{h}</th>' for h in ['State (icon + words)', 'What it promises', 'Where it shows', 'Announced']) + '</tr></thead><tbody>' + tr + '</tbody></table></div>')

def states_sheet():
    """D5: disabled, selected, expanded, collapsed, focused, error with announcement."""
    chip = lambda t, st: f'<span style="height:44px;padding:0 16px;border-radius:22px;display:inline-flex;align-items:center;font:700 14px Manrope;{st}">{t}</span>'
    return ('<div style="width:1100px;border-radius:20px;background:#FFFDF9;box-shadow:inset 0 0 0 1px rgba(36,31,43,.08);padding:20px;display:grid;grid-template-columns:repeat(2,1fr);gap:18px;font-family:Manrope;color:#241F2B">'
            '<div><div style="font:700 12px Manrope;color:#6A6273;margin-bottom:8px">Buttons · enabled / disabled (Sync now while syncing) / focused</div><div style="display:flex;gap:12px;align-items:center">'
            + chip('Sync now', 'background:#11615C;color:#FFFFFF') + chip('Sync now', 'background:#F1ECE4;color:#8A8494') + chip('Try again', 'background:#E2EFEC;color:#0B4642;box-shadow:0 0 0 2px #FFFDF9,0 0 0 4px #11615C') + '</div></div>'
            '<div><div style="font:700 12px Manrope;color:#6A6273;margin-bottom:8px">Selected · tab and segmented (check + weight, not colour alone)</div><div style="display:flex;gap:8px;align-items:center;height:44px;padding:3px;border-radius:22px;background:rgba(36,31,43,.06);width:max-content">'
            + chip('✓ Week', 'background:#FFFDF9;box-shadow:0 1px 3px rgba(36,31,43,.16);height:38px') + chip('Month', 'color:#4E4757;font-weight:600;height:38px') + '</div></div>'
            '<div><div style="font:700 12px Manrope;color:#6A6273;margin-bottom:8px">Expanded / collapsed · Earlier fold and Plan sections (chevron + aria-expanded)</div>'
            '<div style="display:flex;flex-direction:column;gap:6px"><span style="display:flex;align-items:center;gap:8px;min-height:44px;font:700 15px Manrope">' + ico('<path d="M9 6l6 6-6 6"></path>', 16) + 'Earlier</span>'
            '<span style="display:flex;align-items:center;gap:8px;min-height:44px;font:700 15px Manrope">' + ico('<path d="M6 9l6 6 6-6"></path>', 16) + 'Routines<span style="margin-left:auto;font:500 13px Manrope;color:#4E4757">drag onto a day</span></span></div></div>'
            '<div><div style="font:700 12px Manrope;color:#6A6273;margin-bottom:8px">Error at a field · announced, kept with the input, 44 pt target</div>'
            '<div style="border-radius:16px;box-shadow:inset 0 0 0 2px #241F2B;padding:10px 14px;font:700 17px Manrope">What is it?<span style="color:#6F6978;font-weight:500"> (empty)</span></div>'
            '<div role="alert" style="display:flex;gap:6px;align-items:center;margin-top:6px;font:600 13px Manrope;color:#241F2B">' + ico(I_ALERT, 15) + 'Give the task a name to add it.</div></div>'
            '</div>')

def notes(title, items, w=1100):
    return (f'<div style="width:{w}px;border-radius:18px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.10);padding:20px 24px;font:500 15px/22px Manrope;color:#4E4757;display:flex;flex-direction:column;gap:8px">'
            f'<div style="font:800 19px Manrope;color:#241F2B">{title}</div>' + ''.join(f'<div>{i}</div>' for i in items) + '</div>')

def row(t, sub, items):
    return (f'<div style="display:flex;flex-direction:column;gap:16px"><div><div style="font-size:26px;font-weight:800">{t}</div><div style="font-size:16px;color:#4E4757;max-width:3400px">{sub}</div></div>'
            f'<div style="display:flex;gap:40px;row-gap:36px;align-items:flex-start;flex-wrap:wrap">{"".join(items)}</div></div>')

def build():
    P = iph(); A = andr(); D = desk(); Z = 0.78; ZD = 0.5
    ph = lambda k, d, t, n: pair(k, d, 390, 844, Z, t, n)
    an = lambda k, d, t, n: pair(k, d, 412, 892, Z * 390 / 412, t, n)
    dk = lambda k, d, t, n: pair(k, d, 1280, 800, ZD, t, n)
    secA = [ph('A1', P['A1'], 'Opening · loading from this device', ['Still skeleton dots on the dotted thread, only if reading takes over 300 ms; no spinner, no percentage. VoiceOver/TalkBack: "Loading". Tasks are never shown as gone.']),
            ph('A2', P['A2'], 'New device · first sync', ['"Bringing your tasks to this device…" with the real count from the server ("12 of 40"); tasks appear as they arrive. Offline: the screen does not wait.']),
            ph('A3', P['A3'], 'Syncing existing tasks', ['Everything stays on screen; only the header button shows a ring and says "Syncing". No pull-to-refresh is needed (sync runs on change, resume and Realtime).']),
            ph('A4', EMPTY, 'Empty Today (approved, unchanged)', ['The approved empty day (ED-079 era) is the kit\'s empty Today: calm, no shame, Add / Drop a routine / Plan from Inbox.'], ),
            ph('A5', inbox_empty(), 'Empty Inbox', ['"Inbox is clear" (app copy) with what the Inbox is for. The Inbox tab is selected; its badge disappears.']),
            ph('A6', P['A6'], "Didn't load · Try again", ['"This didn\'t load · Your tasks are safe on this device." Try again re-reads this device; nothing is sent.']),
            an('A7', A['A7'], 'Android · couldn\'t save', ['Material snackbar, announced assertively. The editor and its text stay open; Try again repeats the same save (same task id), so it cannot create a second task.']),
            ]
    secA2 = [dk('A8', D['A8'], 'Web · open in another tab', ['Different action, not retry: "Use it here" (app copy). The other tab then shows "You chose to use Dottoday in another tab. Your tasks are saved."']),
             dk('A9', D['A9'], 'Web · offline before the app has ever opened', ['Shown only when the browser has never cached Dottoday (offline.html, app copy). After one visit the service worker serves the app offline. Caching of every file is not yet verified (PENDING).']),
             dk('A10', D['A10'], 'Mac · session ended', ['Different action: Sign in…; tasks stay on this device. Implementation dependency: today an expired session during sync shows the generic "Couldn\'t sync" (CR-158).'])]
    secB = [ph('B2', P['B2'], 'iPhone · offline', ['Existing banner copy "Offline · everything still works here"; the header icon becomes a crossed cloud. Edits keep saving on the device first.']),
            an('B3', A['B3'], 'Android · offline with changes waiting', ['Same banner; the header button carries a "3" badge: "3 changes waiting to sync".']),
            ph('B4', P['B4'], 'iPhone · sync sheet · couldn\'t sync', ['App copy for state, last sync and the outbox count. Sync now resends the same saved changes; it cannot duplicate a task (ids and per-field clocks).']),
            dk('B5', D['B5'], 'Mac · sidebar line and Sync popover', ['The sidebar line under the Plan panel carries the state; the popover shows detail. Sync now is disabled (dimmed and announced) while offline.']),
            dk('B6', D['B6'], 'Web · saved in this browser', ['Web says "Saved in this browser" (not "on this device"); see decision Q2 about asking the browser to keep storage.'])]
    secC = [ph('C1', P['C1'], 'Conflict · noticed', ['The other device\'s value is in use (Deep work moved to 9:30). Banner "1 change needs you · Review"; nothing is lost; work continues.']),
            ph('C2', P['C2'], 'Conflict · review', ['One card per detail: This device / Other device, Keep mine / Keep theirs with equal weight. Nothing is overwritten until you choose.']),
            ph('C3', P['C3'], 'Conflict · resolved', ['Banner and badge clear. The toast says what was kept. Undo is drawn as proposed (decision Q3); the app has no Undo here today.']),
            dk('C4', D['C4'], 'Mac · same journey in the Sync popover', ['From the sidebar line "1 change needs you". Keyboard: Tab to the card, Return chooses; VoiceOver reads both values.'])]
    secD = [ph('D1', P['D1'], 'iPhone · largest text (about 200 %)', ['One column; times above titles; nothing truncated; dots 44 pt; the tab bar keeps icons and shows labels in the large-content viewer on long press. Android font scale 200 % follows the same layout.']),
            ph('D3', P['D3'], 'VoiceOver / TalkBack', ['Focus rectangle on the now card and the spoken label. Announcements: sync changes are polite and spoken once; a failed save is assertive.']),
            ph('D4', P['D4'], 'Reduce Transparency + Increase Contrast', ['Glass becomes solid with a 1.5 px outline; secondary text one step darker; the dotted thread stronger. Reduced Motion: the sync ring and sheets appear without animation.']),
            dk('D2', D['D2'], 'Mac/web · keyboard order', ['Tab order: sidebar → toolbar → Plan panel → week → inspector; focus ring 2 px gap + teal (ED-178). Esc closes popovers and returns focus.'])]
    head = ('<header><h1 style="margin:0;font-size:38px;line-height:44px;font-weight:700;letter-spacing:-0.6px">G4-7 · Shared states and accessibility · one kit for every platform · for your review (not merged)</h1>'
            '<p style="margin:8px 0 0;font-size:18px;color:#4E4757">Approved direction: option A (ED-186). Each state in light and dark (final P1 map). Wording comes from the app where it exists; new wording is marked proposed. '
            'What a message promises was checked read-only against the app: changes save on the device first, an outbox holds them until the server accepts them, retries resend the same ids, conflicts are per field and keep the other device\'s value until you choose.</p></header>')
    qs = notes('Decisions for you (nothing below is merged)', [
        '<b>Q1 · Approve the kit\'s look</b> (this board): loading, empty, errors, sync status, conflict journey, accessibility frames.',
        '<b>Q2 · Web storage</b>: the browser can clear web data unless the app asks it to keep it. Recommended: ask the browser to keep storage on sign-in, and until then say "Saved in this browser". Implementation dependency, not a design change.',
        '<b>Q3 · Undo after resolving a conflict</b>: the app has none. Recommended: add Undo to the toast for 10 s (it re-applies the value you replaced).',
        '<b>Q4 · "Keep both"</b> for text details (title, notes): not in the app. Recommended: not now; Keep mine / Keep theirs only, revisit if people ask.',
        '<b>Q5 · CR-154 follow-up</b>: the approved #6F6978 reaches 5.45:1 on most surfaces but 4.24:1 on two tinted Android Create task headers (#E8E5EE, #F0E3E5). Recommended: #6A6473 for that placeholder (4.57:1), or keep #6F6978 and lighten those headers.',
        'Implementation, not design: CR-158 expired session during sync should say "Sign in again"; one-tap retries must reuse the same task id; device, VoiceOver, TalkBack, Reduce Transparency, Increase Contrast and offline web caching stay PENDING.'], 1600)
    tab = notes('Native behaviour per platform', [
        '<b>iPhone:</b> system sheet and alert styles, Dynamic Type to AX5, VoiceOver rotor, Reduce Transparency swaps glass for solid (iOS 26 and the iOS 16–18 fallback alike).',
        '<b>Android:</b> Material snackbar and progress, TalkBack, font scale 200 %, the custom toolbar turns solid when blur is off.',
        '<b>Mac:</b> popover from the sidebar line, keyboard focus order, VoiceOver, vibrancy falls back to solid under Reduce Transparency.',
        '<b>Web:</b> aria-live status, focus rings, Back/Forward and refresh keep the open sheet\'s URL (ED-097); offline page only before the first visit.',
        '<b>Tablets:</b> inherit every state; presentations in Prompt D Round 2.'], 1600)
    body = ('<div style="width: 3600px; height: 6440px; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 46px; overflow: hidden;">'
            + head + '<div style="display:flex;gap:40px">' + qs + tab + '</div>'
            + row('A · Loading, empty and errors', 'Phones at 78 %, desktops at 50 %.', secA + secA2)
            + row('B · Sync status', 'One vocabulary everywhere; icon + words, never colour alone.', [specimen()] + secB)
            + row('C · Sync conflict, from noticed to resolved', 'Retrying a network operation resends the same saved changes; it never submits a task again.', secC)
            + row('D · Accessibility', 'Real layouts, not just notes.', secD + [states_sheet()]) + '</div>')
    head_html = open('h/head.html').read().replace('<title>E · Responsive</title>', '<title>E · G4-7 states</title>').replace('</style>', S3.BLKCSS + DK.darkify(S3.BLKCSS).replace('.blk{', '.blk-d{') + 'button{color:inherit}</style>', 1)
    tail = '\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":3600,"height":6440}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n'
    return head_html + body + tail

if __name__ == '__main__':
    open('w96/project/E-G4-7-States.dc.html', 'w').write(build()); print('ok')
