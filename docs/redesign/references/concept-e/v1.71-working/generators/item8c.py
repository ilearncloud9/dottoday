"""Cleanup item 8c (owner, 2026-11-09): iPad Air 'Alarms off' tag only -> neutral tag + amber bell-off icon."""
import sys
T = 'Alarms off for Dottoday · fix it on the iPad'
OLD = ('<span style="display: inline-block; margin-top: 3px; font-size: 12px; font-weight: 600; '
       'padding: 1px 7px; border-radius: 6px; background: {bg}; color: {fg};">' + T + '</span>')
ICON = ('<svg class="i" width="13" height="13" viewBox="0 0 24 24" aria-hidden="true" '
        'style="color: {ic}; stroke-width: 2.4; vertical-align: -2px; margin-right: 4px;"><path d="M6 8a6 6 0 1112 0c0 7 3 9 3 9H3s3-2 3-9'
        'M10 21a2 2 0 004 0M3 3l18 18"></path></svg>')
NEW = ('<span style="display: inline-block; margin-top: 3px; font-size: 12px; '
       'font-weight: 600; padding: 1px 7px 1px 6px; border-radius: 6px; background: {bg}; color: {fg};">'
       + ICON + T + '</span>')
SETS = {'E-Phones': (('#FBEBD0', '#6E4300'), ('#F1ECE4', '#4E4757', '#AF7E22')),
        'E-Phones-Dark': (('#483924', '#E9B864'), ('#2F2A30', '#C7BEC4', '#D9A441'))}
d = sys.argv[1]
for b, (o, n) in SETS.items():
    p = f'{d}/{b}.dc.html'
    s = open(p).read()
    old = OLD.format(bg=o[0], fg=o[1])
    assert s.count(old) == 1, b
    s = s.replace(old, NEW.format(bg=n[0], fg=n[1], ic=n[2]))
    open(p, 'w').write(s)
    print(b, 'ok')
