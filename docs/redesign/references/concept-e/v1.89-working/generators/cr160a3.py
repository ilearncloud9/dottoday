"""E-CR160 A3 (owner, 2026-11-09): accurate device-storage wording; decorative illustration."""
import sys
p = f'{sys.argv[1]}/SignedOut.dc.html'; s = open(p).read()
reps = [('Your tasks are kept safely on this device. They come back when you sign in again with the same account.',
         'Your tasks stay on this device under your account. They come back when you sign in again with the same account.'),
        ('<svg width="96" height="96" viewBox="0 0 96 96" fill="none" role="img" aria-label="An empty day">',
         '<svg width="96" height="96" viewBox="0 0 96 96" fill="none" aria-hidden="true">')]
for o, n in reps:
    assert s.count(o) == 1, o[:40]; s = s.replace(o, n)
open(p, 'w').write(s); print('ok')
