"""E-CR160 (owner, 2026-11-09): Android A2 gets the approved hint under Stay signed in, as on iPhone A2."""
import sys
O = 'font-family: Roboto, sans-serif; font-size: 14px; font-weight: 500;">Stay signed in</button>'
N = O + '\n      <div style="font-size: 13px; line-height: 18px; color: {{t.secondary}}; text-align: center;">Dottoday tries to sync them now.</div>'
for b in ['AndroidA2', 'AndroidA2Unconfirmed']:
    p = f'{sys.argv[1]}/{b}.dc.html'; s = open(p).read(); assert s.count(O) == 1, b
    open(p, 'w').write(s.replace(O, N)); print(b, 'ok')
