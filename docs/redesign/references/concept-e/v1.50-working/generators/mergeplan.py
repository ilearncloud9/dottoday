"""ED-184: merge the approved A + B Plan panel (collapsible panel with collapsible sections) into the active light boards.
Reads src88/project, writes src90/project (full set) and w90/project (changed boards)."""
import re, sys, shutil, glob, os
sys.path.insert(0, 'h')
from bal import elem

ICON = '<svg class="i" width="17" height="17" viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="4.5" width="17" height="15" rx="2.5"></rect><path d="M9.5 4.5v15"></path></svg>'
CHEV = '<span aria-hidden="true" style="display: inline-flex; color: #6A6273; margin-right: 4px;"><svg class="i" width="11" height="11" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6"></path></svg></span>'
PIN = '<svg class="i" width="14" height="14" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 4h6l-1 6 3 3H7l3-3z"></path><path d="M12 13v7"></path></svg>'
CLOSE = '<svg class="i" width="13" height="13" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"></path></svg>'

def toggle(pressed, web=False):
    h, r = ('32px', '22px') if web else ('30px', '21px')
    key = '' if web else ', Option Command P'
    if pressed:
        return (f'<button aria-label="Hide Plan panel{key}" aria-pressed="true" style="width: 34px; height: {h}; flex: none; border: 0; border-radius: {r}; '
                f'background: rgba(17,97,92,.12); color: #0B4642; display: flex; align-items: center; justify-content: center;">{ICON}</button>')
    return (f'<button aria-label="Show Plan panel{key}" aria-pressed="false" style="width: 34px; height: {h}; flex: none; border: 0; border-radius: {r}; '
            f'background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); color: #4E4757; display: flex; align-items: center; justify-content: center;">{ICON}</button>')

def add_toggle(w, pressed, web=False):
    i = w.index('role="toolbar" aria-label="Plan"'); j = w.index('>', i) + 1
    return w[:j] + toggle(pressed, web) + w[j:]

MAC_COL = '<div style="padding: 6px 12px 12px; display: flex; flex-direction: column; gap: 7px; overflow: hidden;">'

def mac_sections(w):
    """B: the three section headers fold (open by default); Capture stays on top."""
    a = w.index(MAC_COL); e = elem(w, a); p = w[a:e]
    p = p.replace('<div style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 8px; padding: 0 2px;"><span style="font-size: 13px; font-weight: 700;">Inbox</span>',
                  '<div role="button" aria-expanded="true" aria-label="Inbox section" style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 8px; padding: 0 2px;"><span style="font-size: 13px; font-weight: 700;">' + CHEV + 'Inbox</span>')
    p = p.replace('<div style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 10px; padding: 0 2px;"><span style="font-size: 13px; font-weight: 700;">Routines</span>',
                  '<div role="button" aria-expanded="true" aria-label="Routines section" style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 10px; padding: 0 2px;"><span style="font-size: 13px; font-weight: 700;">' + CHEV + 'Routines</span>')
    p = re.sub(r'<div style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 10px; padding: 0 2px;"><label for="([^"]+)" style="font-size: 13px; font-weight: 700;">Brain dump</label>',
               lambda m: f'<div role="button" aria-expanded="true" aria-label="Brain dump section" style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 10px; padding: 0 2px;"><label for="{m.group(1)}" style="font-size: 13px; font-weight: 700;">{CHEV}Brain dump</label>', p)
    assert p.count('aria-expanded="true"') == 3, p.count('aria-expanded="true"')
    return w[:a] + p + w[e:]

def web_sections(s):
    i = s.index('<!-- web Inbox column -->'); a = s.index('<div', i); e = elem(s, a); p = s[a:e]
    p = p.replace('<div style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 8px; padding: 0 2px;"><span style="font-size: 13px; font-weight: 700;">Inbox</span>',
                  '<div role="button" aria-expanded="true" aria-label="Inbox section" style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 8px; padding: 0 2px;"><span style="font-size: 13px; font-weight: 700;">' + CHEV + 'Inbox</span>')
    p = p.replace('<div style="display: flex; justify-content: space-between; margin-top: 8px; padding: 0 2px;"><span style="font-size: 13px; font-weight: 700;">Routines</span>',
                  '<div role="button" aria-expanded="true" aria-label="Routines section" style="display: flex; justify-content: space-between; margin-top: 8px; padding: 0 2px;"><span style="font-size: 13px; font-weight: 700;">' + CHEV + 'Routines</span>')
    p = p.replace('<label for="web-dump" style="font-size: 13px; font-weight: 700; margin-top: 8px; padding: 0 2px;">Brain dump</label>',
                  '<div role="button" aria-expanded="true" aria-label="Brain dump section" style="margin-top: 8px; padding: 0 2px;"><label for="web-dump" style="font-size: 13px; font-weight: 700;">' + CHEV + 'Brain dump</label></div>')
    assert p.count('aria-expanded="true"') == 3
    return s[:a] + p + s[e:]

def windows(s, size):
    return [m.start() for m in re.finditer(rf'<div style="position: relative; width: {size}; ', s)]

def map_windows(s, size, fn, only=None):
    pos = windows(s, size)
    for n, w0 in reversed(list(enumerate(pos))):
        if only is not None and n not in only: continue
        w1 = elem(s, w0); s = s[:w0] + fn(s[w0:w1]) + s[w1:]
    return s

def mac_window(w, pressed=True):
    if MAC_COL not in w: return w
    return add_toggle(mac_sections(w), pressed)

def hide_mac(w):
    a = w.index(MAC_COL); e = elem(w, a); w = w[:a] + w[e:]
    w = w.replace('grid-template-columns: 196px 620px 248px;', 'grid-template-columns: 816px 248px;')
    w = w.replace('grid-template-columns: 196px minmax(0, 1fr) 248px;', 'grid-template-columns: minmax(0, 1fr) 248px;')
    w = w.replace('grid-template-columns: 196px minmax(0, 1fr);', 'grid-template-columns: minmax(0, 1fr);')
    return w.replace('aria-label="Hide Plan panel, Option Command P" aria-pressed="true" style="width: 34px; height: 30px; flex: none; border: 0; border-radius: 21px; background: rgba(17,97,92,.12); color: #0B4642;',
                     'aria-label="Show Plan panel, Option Command P" aria-pressed="false" style="width: 34px; height: 30px; flex: none; border: 0; border-radius: 21px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); color: #4E4757;')

def float_panel(w, inner, container_marker):
    head = ('<div style="display: flex; align-items: center; gap: 6px; padding: 10px 12px 2px;"><span style="flex: 1; font: 700 13px Manrope, system-ui, sans-serif;">Plan</span>'
            f'<button aria-label="Keep the Plan panel open" title="Keep open" style="width: 26px; height: 26px; border: 0; border-radius: 13px; background: rgba(36,31,43,.06); color: #4E4757; display: flex; align-items: center; justify-content: center;">{PIN}</button>'
            f'<button aria-label="Close" style="width: 26px; height: 26px; border: 0; border-radius: 13px; background: rgba(36,31,43,.06); color: #4E4757; display: flex; align-items: center; justify-content: center;">{CLOSE}</button></div>')
    panel = ('<div role="dialog" aria-label="Plan panel" aria-modal="false" style="position: absolute; left: 10px; top: 62px; bottom: 12px; width: 236px; z-index: 30; border-radius: 16px; '
             'background: #F6F1EA; box-shadow: 0 0 0 .5px rgba(36,31,43,.20), 0 18px 40px rgba(36,31,43,.22), 0 4px 10px rgba(36,31,43,.08); display: flex; flex-direction: column; overflow: hidden; font-family: Manrope, system-ui, sans-serif; color: #241F2B;">'
             + head + inner + '</div>')
    i = w.index(container_marker); e = elem(w, i)
    return w[:e - 6] + panel + w[e - 6:]

MAC_MAIN = '<div style="position: absolute; left: 216px; top: 0; right: 0; bottom: 0; display: flex; flex-direction: column;">'

def frame(w, zoom, ww, wh, title, notes):
    box = f'<div style="width: {int(ww*zoom)}px; height: {int(wh*zoom)}px; overflow: hidden; flex: none;"><div style="zoom: {zoom};">{w}</div></div>'
    cap = (f'<div style="width: {int(ww*zoom)}px; font-size: 14px; line-height: 20px; color: #4E4757;"><div style="font-weight: 800; font-size: 16px; color: #241F2B;">{title}</div>'
           + ''.join(f'<div>{n}</div>' for n in notes) + '<span class="tb" style="margin-top: 6px;">Approved · A + B (ED-184)</span></div>')
    return f'<section aria-label="{title}" style="display: flex; flex-direction: column; gap: 10px;">{box}{cap}</section>'

def fulla(s):
    # web column found before mac windows are touched
    s = web_sections(s)
    wi = s.index('<!-- web Inbox column -->'); wa = s.index('<div', wi); web_col = s[wa:elem(s, wa)]
    # web window: toggle at the toolbar start
    web_tb = 'role="toolbar" aria-label="Plan" style="height: 52px; flex: none; display: flex; align-items: center; gap: 8px; padding: 0 14px;'
    k = s.index(web_tb); j = s.index('>', k) + 1; s = s[:j] + toggle(True, web=True) + s[j:]
    s = map_windows(s, '1280px', lambda w: mac_window(w, True))
    # View menu and keys table
    s = s.replace('<span aria-hidden="true" style="position: absolute; left: 8px;">✓</span>Show Sidebar<span style="font-size: 12px; color: #6A6273;">⌃⌘S</span></div>',
                  '<span aria-hidden="true" style="position: absolute; left: 8px;">✓</span>Show Sidebar<span style="font-size: 12px; color: #6A6273;">⌃⌘S</span></div>'
                  '<div role="menuitemcheckbox" aria-checked="true" style="height: 22px; display: flex; align-items: center; justify-content: space-between; padding: 0 9px; border-radius: 5px; padding-left: 22px; position: relative;"><span aria-hidden="true" style="position: absolute; left: 8px;">✓</span>Show Plan Panel<span style="font-size: 12px; color: #6A6273;">⌥⌘P</span></div>', 1)
    s = s.replace('>Show Inspector · Show Sidebar</th><td style="text-align: left; vertical-align: top; padding: 5px 8px; font-weight: 700; border-bottom: 1px solid rgba(36,31,43,.07);">⌥⌘I · ⌃⌘S</td>',
                  '>Show Inspector · Show Sidebar · Show Plan Panel</th><td style="text-align: left; vertical-align: top; padding: 5px 8px; font-weight: 700; border-bottom: 1px solid rgba(36,31,43,.07);">⌥⌘I · ⌃⌘S · ⌥⌘P</td>', 1)
    # new row: hidden and brought out, Mac and web
    W = windows(s, '1280px'); mac = s[W[0]:elem(s, W[0])]
    macp = mac[mac.index(MAC_COL):elem(mac, mac.index(MAC_COL))]
    mac_hidden = add_friday(hide_mac(mac))
    webw = s[W[1]:elem(s, W[1])]
    web_hidden = webw.replace(web_col, '').replace('grid-template-columns: 208px 576px 280px;', 'grid-template-columns: 784px 280px;')
    web_hidden = web_hidden.replace('aria-label="Hide Plan panel" aria-pressed="true" style="width: 34px; height: 32px; flex: none; border: 0; border-radius: 22px; background: rgba(17,97,92,.12); color: #0B4642;',
                                    'aria-label="Show Plan panel" aria-pressed="false" style="width: 34px; height: 32px; flex: none; border: 0; border-radius: 22px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); color: #4E4757;')
    web_main = web_hidden[web_hidden.index('role="toolbar" aria-label="Plan"') - 400:]
    pm = re.search(r'<div style="[^"]*">\s*<div role="toolbar" aria-label="Plan"', web_hidden)
    web_marker = pm.group(0)[:pm.group(0).index('>') + 1]
    web_float = float_panel(web_hidden, web_col.replace('padding: 12px;', 'padding: 6px 12px 12px; flex: 1;', 1), web_marker)
    mac_float = float_panel(mac_hidden, macp, MAC_MAIN)
    Z = 0.5
    row = ('<section aria-label="Plan panel, hidden and brought out" style="display: flex; flex-direction: column; gap: 14px;"><div style="display: flex; align-items: baseline; gap: 14px;">'
           '<h2 style="margin: 0; font-size: 24px; font-weight: 700;">Plan panel · hide it, bring it back</h2><span class="tb">Approved · A + B (ED-184)</span>'
           '<span style="font-size: 14px; color: #4E4757;">Toolbar button, View › Show Plan Panel ⌥⌘P (Mac), ⌘K "Hide Plan panel" (web), or drag its edge; sections fold with their chevrons.</span></div>'
           '<div style="display: flex; gap: 40px; align-items: flex-start;">'
           + frame(mac_hidden, Z, 1280, 800, 'Mac · hidden by you', ['The week gains 196 px: Mon–Fri. ⌘N Capture, ⇧⌘N Brain dump and the sidebar items still work. Remembered per window.'])
           + frame(mac_float, Z, 1280, 800, 'Mac · brought out', ['Over the grid, no squeeze. Drop a task on the grid, Esc or click away closes it; the pin docks it again.'])
           + frame(web_hidden, Z, 1280, 800, 'Web · hidden by you', ['The day gains 208 px. Same button; ⌘K "Show Plan panel". Remembered in this browser.'])
           + frame(web_float, Z, 1280, 800, 'Web · brought out', ['Same floating panel and sections; Esc closes, focus returns to the button.'])
           + '</div></section>')
    root = s.index('<div style="width: 2760px; height: 6780px;'); re_ = elem(s, root)
    s = s[:re_ - 6] + row + s[re_ - 6:]
    s = s.replace('width: 2760px; height: 6780px;', 'width: 2760px; height: 7400px;', 1).replace('"height":6780', '"height":7400')
    return s

def add_friday(w):
    g0 = w.index('role="grid" aria-label="Week of 2 November'); g0 = w.rfind('<div', 0, g0); g1 = elem(w, g0); g = w[g0:g1]
    g = g.replace('Monday to Thursday visible', 'Monday to Friday visible').replace('width: 576px; height: 46px; display: grid; grid-template-columns: repeat(4,', 'width: 720px; height: 46px; display: grid; grid-template-columns: repeat(5,')
    thu = g.rfind('<div role="columnheader"'); thu_e = elem(g, thu)
    g = g[:thu_e] + ' ' + g[thu:thu_e].replace('>Thu<', '>Fri<').replace('>5<', '>6<') + g[thu_e:]
    k = g.index('<div aria-hidden="true">') + len('<div aria-hidden="true">')
    g = g[:k] + '<div style="position: absolute; left: 620px; top: 46px; width: 1px; height: 702px; background: rgba(36,31,43,.07);"></div>' + g[k:]
    blocks = [g[m.start():elem(g, m.start())].replace('Thursday', 'Friday').replace('left: 480px;', 'left: 624px;', 1)
              for m in re.finditer(r'<button class="blk"(?: title="[^"]*")? aria-label="[^"]*Thursday[^"]*" style="left: 480px;', g)]
    g = g[:-6] + ''.join(blocks) + g[-6:]
    return w[:g0] + g + w[g1:]

def narrow_fit(w, size):
    """Toolbars with the new Plan button still fit (rules §12.3): 960 tightens the date pill by 4 px; 1042 shows search as its icon + ⌘K, as at 840 and 960."""
    if size == '960px':
        return w.replace('aria-label="2 to 8 November 2026, choose a date" style="height: 30px; padding: 0 10px 0 12px;', 'aria-label="2 to 8 November 2026, choose a date" style="height: 30px; padding: 0 8px 0 10px;', 1)
    a = w.find('<button style="width: 176px; height: 30px;')
    if a < 0: return w
    e = elem(w, a)
    icon = ('<button aria-label="Search or run, Command K" style="height: 30px; border: 0; border-radius: 21px; background: #FFFDF9; box-shadow: 0 0 0 1px rgba(36,31,43,.10); display: flex; align-items: center; gap: 5px; padding: 0 9px; font: 13px -apple-system, system-ui, sans-serif; color: #4E4757;">'
            '<svg class="i" width="14" height="14" viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="M20 20l-4-4"></path></svg><span style="font-size: 11px; color: #6A6273;">⌘K</span></button>')
    return w[:a] + icon + w[e:]

def narrow(s):
    s = map_windows(s, '960px', lambda w: narrow_fit(mac_window(w, True), '960px') if MAC_COL in w else w)
    s = map_windows(s, '1042px', lambda w: narrow_fit(mac_window(w, True), '1042px') if MAC_COL in w else w)
    s = map_windows(s, '1160px', lambda w: mac_window(w, True))
    s = map_windows(s, '1280px', lambda w: mac_window(w, True))
    # 840: the panel hides on its own (the grid would show fewer than 3 days)
    s = map_windows(s, '840px', lambda w: hide_mac(mac_window(w, True)) if MAC_COL in w else w)
    old = 'Sidebar 216, Inbox 196, the week grid shows the days that fit (Today kept in view); the inspector floats.'
    assert old in s
    s = s.replace(old, 'Sidebar 216; the Plan panel hides on its own here (the week would show fewer than 3 days), so the week shows Mon–Thu (Today kept in view); the toolbar button or ⌥⌘P brings it out over the grid (ED-184). The inspector floats.')
    return s

def run():
    os.makedirs('src90/project', exist_ok=True); os.makedirs('w90/project', exist_ok=True)
    for f in glob.glob('src88/project/*.dc.html'): shutil.copy(f, 'src90/project/')
    out = {'E-FullA-v2': fulla(open('src88/project/E-FullA-v2.dc.html').read()),
           'E-G4-3-Narrow': narrow(open('src88/project/E-G4-3-Narrow.dc.html').read())}
    for b, x in out.items():
        open(f'src90/project/{b}.dc.html', 'w').write(x); open(f'w90/project/{b}.dc.html', 'w').write(x)
    print('ok')

if __name__ == '__main__': run()
