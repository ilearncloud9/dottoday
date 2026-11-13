"""E-CR160 A2 (owner, 2026-11-09): narrower device-storage sentence until isolation (I1–I8, physical devices) is verified."""
import json, sys
d = sys.argv[1]
OLD = 'Until then, no one else who uses Dottoday on this device can see them.'
NEW = 'They stay on this device under this account.'
for b in ['Main', 'AndroidA2', 'DesktopA2']:
    p = f'{d}/{b}.dc.html'; s = open(p).read(); assert s.count(OLD) == 1, b
    open(p, 'w').write(s.replace(OLD, NEW)); print(b, 'ok')
p = f'{d}/canvas.json'; c = json.load(open(p))
t = c['notes']['condA']['text']
old = "A2's last sentence (\"no one else … can see them\") ships only after"
assert old in t
c['notes']['condA']['text'] = t.replace(old, "A2's last sentence is \"They stay on this device under this account.\" (2026-11-09). The fuller \"Until then, no one else who uses Dottoday on this device can see them.\" replaces it only after")
json.dump(c, open(p, 'w'), indent=1, ensure_ascii=False); print('note ok')
