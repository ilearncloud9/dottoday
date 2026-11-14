# One icon per Settings row, the same on every platform (owner comment on R2-29, 14 Nov 2026).
# Glyph and colour per row: the approved iPhone tile where one was drawn (E-Phones, R2-20 to R2-24),
# otherwise the app's own glyph and tint (features/settings, SettingsRow glyph/tint) in the same tile palette.
# Shape follows each platform's approved Settings anatomy: a 30 px rounded tile on iPhone, iPad, Mac and web,
# a 40 px circle on Android (E-Phones Android Settings, ED-084); the Mac toolbar uses its 22 px tile.
import re, json, os, sys

PAL = {  # light bg, light fg, dark bg, dark fg (pairs read from the approved light and dark boards)
    'teal': ('#E2EFEC', '#0B4642', '#1E3A37', '#A3E2D9'),
    'green': ('#E3F1E7', '#1D6436', '#1E3A37', '#A3E2D9'),
    'violet': ('#E6E3F7', '#4B3FB0', '#333148', '#A9ACEB'),
    'indigo': ('#E4E3F7', '#4B3FB0', '#302F48', '#A9ACEB'),
    'amber': ('#FBEBC8', '#9A5A0E', '#483924', '#D9A23A'),
    'grey': ('#EDE7DF', '#4E4757', '#2F2A30', '#C7BEC4'),
    'pink': ('#F6E2EA', '#9C3D63', '#523342', '#F2A7C1'),
}
BG2KEY = {v[0]: k for k, v in PAL.items()}

P = {
    'sun': '<circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"></path>',
    'sunrise': '<path d="M3 18h18M6 14a6 6 0 0 1 12 0M12 4v3M5 8l1.5 1.5M19 8l-1.5 1.5"></path>',
    'alarm': '<circle cx="12" cy="13" r="7"></circle><path d="M12 10v3l2 2M5 4L2 7M19 4l3 3"></path>',
    'moon': '<path d="M20 14.5A8 8 0 019.5 4a8 8 0 1010.5 10.5z"></path>',
    'bell': '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4zM10 20a2 2 0 0 0 4 0"></path>',
    'bell2': '<path d="M6 8a6 6 0 1112 0c0 7 3 9 3 9H3s3-2 3-9M10 21a2 2 0 004 0"></path>',
    'sound': '<path d="M4 9v6h4l5 4V5L8 9z"></path><path d="M16 9a4 4 0 0 1 0 6M18.5 6.5a7.5 7.5 0 0 1 0 11"></path>',
    'calendar': '<rect x="3" y="5" width="18" height="16" rx="2.5"></rect><path d="M3 10h18M8 3v4M16 3v4"></path>',
    'person': '<circle cx="12" cy="8" r="4"></circle><path d="M4 21a8 8 0 0 1 16 0"></path>',
    'more': '<path d="M5 12h.01M12 12h.01M19 12h.01" style="stroke-width: 3;"></path>',
    'globe': '<circle cx="12" cy="12" r="9"></circle><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"></path>',
    'clock': '<circle cx="12" cy="12" r="8.5"></circle><path d="M12 7.5V12l3 2"></path>',
    'repeat': '<path d="M17 2l3 3-3 3"></path><path d="M4 11V9a4 4 0 0 1 4-4h12M7 22l-3-3 3-3"></path><path d="M20 13v2a4 4 0 0 1-4 4H4"></path>',
    'bolt': '<path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"></path>',
    'check': '<path d="M5 12.5l4.5 4.5L19 7.5"></path>',
    'lock': '<rect x="5" y="11" width="14" height="10" rx="2"></rect><path d="M8 11V8a4 4 0 0 1 8 0v3"></path>',
    'close': '<path d="M6 6l12 12M18 6L6 18"></path>',
    'plus': '<path d="M12 5v14M5 12h14"></path>',
    'roll': '<path d="M3 12h14M13 7l5 5-5 5M21 5v14"></path>',
    'car': '<path d="M5 17H3v-5l2-5h14l2 5v5h-2M9.5 17h5M5.5 17a2 2 0 1 0 4 0a2 2 0 1 0 -4 0M14.5 17a2 2 0 1 0 4 0a2 2 0 1 0 -4 0"></path>',
    'search': '<circle cx="11" cy="11" r="7"></circle><path d="M20 20l-4-4"></path>',
    'phone': '<rect x="7" y="3" width="10" height="18" rx="2"></rect><path d="M11 18h2"></path>',
    'ring': '<path d="M12 4h.01M17.66 6.34h.01M20 12h.01M17.66 17.66h.01M12 20h.01M6.34 17.66h.01M4 12h.01M6.34 6.34h.01" style="stroke-width: 3;"></path>',
    'warn': '<path d="M12 4l9 16H3z"></path><path d="M12 10v4M12 17v.5"></path>',
}

# Rows that never had a tile: (palette, glyph). App glyph and tint, design paths.
NEW = {
    'Wake Up': ('amber', 'sunrise'), 'Wake Up alarm': ('amber', 'alarm'), 'Wake Up options': ('amber', 'sound'),
    'Wind Down': ('violet', 'moon'), 'Remind me when a dot starts': ('teal', 'bell'), 'Account and sync': ('teal', 'person'),
    'Everything else…': ('grey', 'more'), 'Language': ('indigo', 'globe'), 'Time format': ('grey', 'clock'),
    'Snooze': ('violet', 'moon'), 'Volume ramp': ('amber', 'sunrise'), 'Vary the sound': ('indigo', 'repeat'),
    'Snooze length': ('teal', 'clock'), 'Snooze limit': ('teal', 'repeat'), 'Missions': ('amber', 'bolt'),
    "Check I've started": ('green', 'check'), "Check I&#39;ve started": ('green', 'check'), 'Backup mission': ('teal', 'check'),
    'Lock Dottoday': ('teal', 'lock'), 'Lock after': ('teal', 'clock'), 'Sign in to connect Google or Microsoft': ('teal', 'person'),
    'Disconnect': ('grey', 'close'), 'Connect Google Calendar': ('teal', 'plus'), 'Connect Microsoft Outlook': ('teal', 'plus'),
    'No calendars connected yet': ('grey', 'calendar'), 'Move calendar events too': ('teal', 'roll'), 'Suggest travel time': ('indigo', 'car'),
    'Connect a calendar': ('violet', 'calendar'), 'Search': ('teal', 'search'), 'Energy suggestions': ('amber', 'bolt'),
    'Wind Down reminder': ('violet', 'bell2'),  # E-Phones (approved) over R2-20's moon
    'General': ('teal', 'person'),
    'Alarm sounds on': ('grey', 'phone'), 'Send a test alarm': ('teal', 'bell'), 'Wake Up card': ('amber', 'sunrise'),
    'Sound and snooze': ('amber', 'sound'), 'Show the night on the day dot': ('violet', 'ring'), 'From': ('grey', 'clock'), 'Until': ('grey', 'clock'),
}
# Status and list rows keep what they show (state icons, colour dots, dates, formats, choices).
SKIP = {'Notifications are on', 'Your clock is right', 'Alarm-grade wake-up is on.', 'Reminders arrive while Dottoday is open',
        'Everything (JSON)', 'Tasks (CSV)', 'Calendar (.ics)', 'Focus', 'Mission'}


def canonical(tiles_json):
    tiles = json.load(open(tiles_json))
    C = {}
    for t, uses in tiles.items():
        if t in SKIP or t.startswith('Nov ') or t.startswith('No backups'):
            continue
        bg, svg = uses[0][1], uses[0][2]
        if bg in BG2KEY:
            C[t] = (BG2KEY[bg], svg)
    for t, (k, g) in NEW.items():
        C[t] = (k, P[g])
    return C


def tile(key, svg, dark, size=30, r=8, icon=18):
    bg, fg = (PAL[key][2], PAL[key][3]) if dark else (PAL[key][0], PAL[key][1])
    return ('<span aria-hidden="true" style="width: %dpx; height: %dpx; border-radius: %dpx; background: %s; color: %s; display: flex; align-items: center; justify-content: center; flex: none;">'
            '<svg class="i" width="%d" height="%d" viewBox="0 0 24 24" aria-hidden="true">%s</svg></span>') % (size, size, r, bg, fg, icon, icon, svg)


def circle(key, svg, dark): return tile(key, svg, dark, 40, 20, 20).replace('border-radius: 20px', 'border-radius: 50%', 1)


ROW = re.compile(r'<(a|div)\b[^>]*?style="([^"]*)"[^>]*>')
LEAD = re.compile(r'^\s*<span aria-hidden="true" style="width: (30px; height: 30px; border-radius: 8px|40px; height: 40px; border-radius: 50%)[^"]*">.*?</svg></span>', re.S)
TOOLBAR = re.compile(r'<span aria-hidden="true" style="width: 22px; height: 22px; border-radius: 6px; background: #[0-9A-Fa-f]{6};[^"]*">(?:<svg.*?</svg>)?</span>([A-Z][^<]{1,30})<', re.S)


def sig(h):
    c = re.search(r'background: ([^;]+); color: ([^;]+);', h)
    inner = re.sub(r'\s+', ' ', re.sub(r'<svg[^>]*>', '', h.split('</svg>')[0].split('>', 1)[1]))
    return (c.groups() if c else None, inner, 'border-radius: 50%' in h)


def transform(s, C, dark, log):
    out, pos = [], 0
    for m in ROW.finditer(s):
        st = m.group(2)
        if m.start() < pos or 'display: flex' not in st or 'align-items: center' not in st or 'flex-direction: column' in st:
            continue
        mh = re.search(r'min-height: (\d+)px', st)
        if not mh or not 40 <= int(mh.group(1)) <= 80:
            continue
        tm = re.search(r'>([^<>]{2,80})<', s[m.end() - 1:m.end() + 1400])
        if not tm:
            continue
        t = tm.group(1).strip()
        if t == 'Notification health':
            after = re.sub(r'<[^>]+>', ' ', s[m.end() - 1 + tm.end():m.end() + 1600])
            C = dict(C, **{t: ('green', P['check']) if 'All good' in after[:200] else ('teal', P['warn'])})
        if t not in C:
            continue
        pre = s[m.end():m.end() - 1 + tm.start()]
        android = 'gap: 16px' in st or ('Roboto' in s[m.end():m.end() + 1400][:tm.start() + 200] and 'gap: 12px' not in st)
        new = circle(*C[t], dark) if android else tile(*C[t], dark)
        lm = LEAD.match(pre)
        if lm:
            if sig(lm.group(0)) == sig(new):
                continue
            out.append(s[pos:m.end()] + new); pos = m.end() + lm.end(); log.append(('replace', t, 'android' if android else 'tile'))
        elif '<svg' in pre or 'border-radius: 50%' in pre or '<img' in pre:
            continue  # rows with their own lead (colour dots, avatars, choices) stay as drawn
        else:
            out.append(s[pos:m.end()] + new); pos = m.end(); log.append(('add', t, 'android' if android else 'tile'))
    s = ''.join(out) + s[pos:]

    def tb(m):
        t = m.group(1)
        k = {'Help': 'Help and about'}.get(t, t)  # the Help pane is the Help and about group
        if k not in C:
            return m.group(0)
        log.append(('toolbar', t, 'mac'))
        return tile(*C[k], dark, 22, 6, 14) + t + '<'
    return TOOLBAR.sub(tb, s)


if __name__ == '__main__':
    C = canonical(sys.argv[1])
    for f in sys.argv[2:]:
        s = open(f, encoding='utf-8').read(); log = []
        n = transform(s, C, '-Dark' in f, log)
        open(f, 'w', encoding='utf-8').write(n)
        from collections import Counter
        print(os.path.basename(f), dict(Counter((a, p) for a, _, p in log)))
