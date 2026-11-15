# Settings page titles carry their page's icon on every platform (owner comment on R2-33, 15 Nov 2026):
# the same glyph and colour as the row that opens the page (ED-332). Apple and web titles get the rounded tile,
# Android's top app bar gets the circle, beside the title text.
import re, os, sys, html
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import settings_icons as SI

ALIAS = {'Learning': 'Learn my day', 'Siri & Shortcuts': 'Siri &amp; Shortcuts'}
EXTRA = {'Sounds': ('indigo', 'sound'), 'Notification health': ('green', 'check'), 'Alarm sounds on': ('grey', 'phone')}
TITLES = ['Your day', 'Planning', 'Reminders', 'Appearance', 'Data and privacy', 'Help and about', 'Wake Up and Wind Down', 'Alarm sounds on',
          'Wake Up options', 'Missions', 'Notification health', 'Sounds', 'Calendars', 'Privacy', 'Export', 'Routines', 'Learn my day', 'Learning',
          'Help', 'About Dottoday', "What's new", 'Siri & Shortcuts', 'Everything else…']


def icon_for(C, t):
    t = html.unescape(t)
    if t in EXTRA:
        k, g = EXTRA[t]
        return k, SI.P[g]
    for key in (t, ALIAS.get(t, t), t.replace("'", '&#39;'), t.replace('&', '&amp;')):
        if key in C:
            return C[key]
    return None


BIG = re.compile(r'<div style="([^"]*font: (?:700|800) (?:2[2-9]|3[0-4])px[^"]*)">([^<]{2,40})</div>')
ANDROID = re.compile(r'<span style="font: 400 22px/28px Roboto, system-ui, sans-serif;">([^<]{2,40})</span></header>')


def transform(s, C, dark, log):
    def big(m):
        st, t = m.group(1), m.group(2)
        if html.unescape(t) not in TITLES or 'display: flex' in st:
            return m.group(0)
        ic = icon_for(C, t)
        if not ic:
            return m.group(0)
        log.append(('title', t))
        return '<div style="%s display: flex; align-items: center; gap: 12px;">%s<span>%s</span></div>' % (st.rstrip(';') + ';', SI.tile(ic[0], ic[1], dark, 34, 9, 20), t)

    def andr(m):
        t = m.group(1)
        ic = icon_for(C, t) if html.unescape(t) in TITLES else None
        if not ic:
            return m.group(0)
        log.append(('android', t))
        c = SI.tile(ic[0], ic[1], dark, 32, 16, 18).replace('border-radius: 16px', 'border-radius: 50%', 1)
        return '<span style="display: flex; margin: 0 12px 0 4px;">%s</span>%s' % (c, m.group(0))
    s = BIG.sub(big, s)
    return ANDROID.sub(andr, s)


if __name__ == '__main__':
    from collections import Counter
    C = SI.canonical(sys.argv[1])
    for f in sys.argv[2:]:
        s = open(f, encoding='utf-8').read(); log = []
        n = transform(s, C, '-Dark' in f, log)
        open(f, 'w', encoding='utf-8').write(n)
        print(os.path.basename(f), dict(Counter(k for k, _ in log)))
