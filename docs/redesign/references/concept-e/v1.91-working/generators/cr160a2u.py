"""E-CR160 (owner, 2026-11-09): A2 'Sync hasn't been confirmed yet' on iPhone, Android, Mac/web (+dark).
Copies of the A2 frames with only the approved count=0 strings swapped; Account status uses the built
syncPending =0 string 'Nothing waiting to sync'."""
import json, sys
d = sys.argv[1]
OLD_T = '3 changes haven’t synced yet'
NEW_T = 'Sync hasn’t been confirmed yet'
OLD_B = 'They’re saved on this device for sam@example.com and haven’t reached your account yet. They can sync when you sign in again with this account. They stay on this device under this account.'
NEW_B = 'Dottoday hasn’t confirmed that everything reached your account. Anything that didn’t is saved on this device for sam@example.com and can sync when you sign in again with this account. They stay on this device under this account.'
OLD_S = '3 changes waiting to sync'
NEW_S = 'Nothing waiting to sync'
pairs = {'Main': 'A2Unconfirmed', 'AndroidA2': 'AndroidA2Unconfirmed', 'DesktopA2': 'DesktopA2Unconfirmed'}
for src, dst in pairs.items():
    s = open(f'{d}/{src}.dc.html').read()
    for o, n in [(OLD_T, NEW_T), (OLD_B, NEW_B), (OLD_S, NEW_S)]:
        assert s.count(o) == 1, (src, o[:30]); s = s.replace(o, n)
    s = s.replace('<title>Sign out with unsynced changes', '<title>Sign out, sync not confirmed', 1)
    for a, b in [('a2-', 'a2u-'), ('aa2-', 'aa2u-'), ('da2-', 'da2u-')]:
        s = s.replace(f'"{a}title"', f'"{b}title"').replace(f'"{a}body"', f'"{b}body"')
    open(f'{d}/{dst}.dc.html', 'w').write(s)
    w = open(f'cr160now/project/{src}Dark.dc.html').read()
    w = w.replace(f'name="{src}"', f'name="{dst}"').replace('<title>Sign out with unsynced changes', '<title>Sign out, sync not confirmed', 1)
    assert f'name="{dst}"' in w
    open(f'{d}/{dst}Dark.dc.html', 'w').write(w)
    print(dst, 'ok')
p = f'{d}/canvas.json'; c = json.load(open(p))
new = {'A2Unconfirmed.dc.html': (2320, 0, 390, 844, 'A2 · Sync not confirmed · light'),
       'A2UnconfirmedDark.dc.html': (2790, 0, 390, 844, 'A2 · Sync not confirmed · dark'),
       'AndroidA2Unconfirmed.dc.html': (6040, 3792, 390, 844, 'A2 · Sync not confirmed · Android · light'),
       'AndroidA2UnconfirmedDark.dc.html': (6510, 3792, 390, 844, 'A2 · Sync not confirmed · Android · dark'),
       'DesktopA2Unconfirmed.dc.html': (6980, 3792, 960, 640, 'A2 · Sync not confirmed · Mac and web · light'),
       'DesktopA2UnconfirmedDark.dc.html': (8020, 3792, 960, 640, 'A2 · Sync not confirmed · Mac and web · dark')}
for k, (x, y, w, h, t) in new.items():
    assert k not in c['boards']; c['boards'][k] = {'x': x, 'y': y, 'w': w, 'h': h, 'title': t}
i = c['order'].index('SignOutPlainDark.dc.html'); c['order'][i+1:i+1] = ['A2Unconfirmed.dc.html', 'A2UnconfirmedDark.dc.html']
i = c['order'].index('DesktopA1Dark.dc.html'); c['order'][i+1:i+1] = ['AndroidA2Unconfirmed.dc.html', 'AndroidA2UnconfirmedDark.dc.html', 'DesktopA2Unconfirmed.dc.html', 'DesktopA2UnconfirmedDark.dc.html']
c['notes']['row4']['maxW'] = 8980
t = c['notes']['condA']['text']; o = 'Otherwise A2.'; assert t.count(o) == 1
c['notes']['condA']['text'] = t.replace(o, 'Otherwise A2: with changes waiting, the count title; with nothing waiting but the last sync unconfirmed, "Sync hasn’t been confirmed yet".')
json.dump(c, open(p, 'w'), indent=1, ensure_ascii=False); print('index ok')
