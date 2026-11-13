"""Cleanup item 12 (owner, 2026-11-09, option A): one repeat marker, the phones' icon.
- Week blocks (11 px): 'Team standup ↻' -> title + 10 px icon.
- Day rows (13.5 px): '↻' after the title and the '· repeats' suffix -> 12 px icon after the time.
- E-Phones: the glyph leaves the title field and the dialog sentence; the schedule line already says
  'repeats on weekdays' (content, unchanged).
The containers' accessible names already include 'repeats', so the icon is aria-hidden there."""
import sys

PATH = '<path d="M17 3l3 3-3 3M20 6H8a4 4 0 00-4 4v1M7 21l-3-3 3-3M4 18h12a4 4 0 004-4v-1"></path>'
ICON10 = ('<svg class="i" width="10" height="10" viewBox="0 0 24 24" aria-hidden="true" '
          'style="vertical-align: -1px; margin-left: 4px;">' + PATH + '</svg>')
ICON12 = ('<svg class="i" width="12" height="12" viewBox="0 0 24 24" aria-hidden="true" '
          'style="vertical-align: -1.5px; margin-left: 5px;">' + PATH + '</svg>')

ROW_OLD = ('Team standup ↻ <span class="num" style="font-size: 12.5px; font-weight: 400;">'
           '· 8:00–8:15 AM · repeats</span>')
ROW_NEW = ('Team standup <span class="num" style="font-size: 12.5px; font-weight: 400;">'
           '· 8:00–8:15 AM' + ICON12 + '</span>')
BLK_OLD = ';">Team standup ↻</span></button>'
BLK_NEW = ';">Team standup' + ICON10 + '</span></button>'
PH = [(';">Team standup ↻</div></div><button aria-label="Mark done"',
       ';">Team standup</div></div><button aria-label="Mark done"'),
      ('You moved Team standup ↻ to <b>8:15 AM</b>', 'You moved Team standup to <b>8:15 AM</b>')]

PLAN = {'E-FullA-v2': [(ROW_OLD, ROW_NEW, 3), (BLK_OLD, BLK_NEW, 22)],
        'E-G4-3-Narrow': [(BLK_OLD, BLK_NEW, 20)],
        'E-Phones': [(o, n, 1) for o, n in PH]}

d = sys.argv[1]
for base, reps in PLAN.items():
    for b in (base, base + '-Dark'):
        p = f'{d}/{b}.dc.html'
        s = open(p).read()
        for old, new, n in reps:
            assert s.count(old) == n, (b, old[:40], s.count(old))
            s = s.replace(old, new)
        assert '↻' not in s, b
        open(p, 'w').write(s)
        print(b, 'ok')
