"""ED-205 contrast refinement (owner, 2026-11-09): light bell-off icon #AF7E22 -> #986C1C on the iPad Air
'Alarms off' tag in E-Phones only. Dark board unchanged."""
import sys
p = f'{sys.argv[1]}/E-Phones.dc.html'; s = open(p).read()
old = 'aria-hidden="true" style="color: #AF7E22; stroke-width: 2.4; vertical-align: -2px; margin-right: 4px;"><path d="M6 8a6 6 0 1112 0c0 7 3 9 3 9H3s3-2 3-9M10 21a2 2 0 004 0M3 3l18 18"></path></svg>Alarms off for Dottoday'
assert s.count(old) == 1
s = s.replace(old, old.replace('#AF7E22', '#986C1C')); open(p, 'w').write(s); print('ok')
