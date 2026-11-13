"""Cleanup item 10 (owner, 2026-11-09, option A): Mac and web Day button -> system font 13/500.
Mac variant (30 px, -apple-system): weight 700 -> 500. Web variant (32 px, Manrope 700) -> system-ui 500.
Only <button> elements whose text starts with "Day"; mobile-web chip (14 px) and phone chips untouched."""
import re, sys
sys.path.insert(0, 'h')
from bal import elem

MAC_OLD = 'font: 700 13px -apple-system, system-ui, sans-serif;'
MAC_NEW = 'font: 500 13px -apple-system, system-ui, sans-serif;'
WEB_OLD = 'font: 700 13px Manrope, system-ui, sans-serif;'
WEB_NEW = "font: 500 13px system-ui, -apple-system, 'Segoe UI', sans-serif;"
BOARDS = ['E-Minimal', 'E-Minimal-Dark', 'E-FullA-v2', 'E-FullA-v2-Dark', 'E-G4-3-Narrow', 'E-G4-3-Narrow-Dark']


def fix(s):
    mac = web = 0
    for m in reversed(list(re.finditer(r'<button\b', s))):
        a = m.start(); e = elem(s, a); t = s[a:e]
        if not re.match(r'Day\b', re.sub(r'<[^>]+>', '', t).strip()):
            continue
        head = t[:t.find('>') + 1]
        if 'height: 30px' in head and MAC_OLD in head:
            head2 = head.replace(MAC_OLD, MAC_NEW); mac += 1
        elif 'height: 32px' in head and WEB_OLD in head:
            head2 = head.replace(WEB_OLD, WEB_NEW); web += 1
        else:
            continue
        s = s[:a] + head2 + s[a + len(head):]
    return s, mac, web


d = sys.argv[1]
for b in BOARDS:
    p = f'{d}/{b}.dc.html'
    s, mac, web = fix(open(p).read())
    open(p, 'w').write(s)
    print(b, 'mac', mac, 'web', web)
