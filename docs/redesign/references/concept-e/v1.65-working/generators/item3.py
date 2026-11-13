"""Cleanup item 3, option A (owner 2026-11-08, ED-199): ahead-ring stroke widths by context. Light and dark; structure-matched, colour-agnostic."""
import re, glob, collections
C=r'#[0-9A-Fa-f]{6}'
RULES=[
 ('proposal 34 phone 3->4', re.compile(r'(width: 34px; height: 34px; border-radius: 50%; background: '+C+r'; box-shadow: inset 0 0 0 )3px( '+C+r'; outline: 2px dashed)'), r'\g<1>4px\g<2>'),
 ('Ahead preview 3.5->4', re.compile(r'(role="img" aria-label="Ahead" style="width: 34px; height: 34px; border-radius: 50%; background: '+C+r'; box-shadow: inset 0 0 0 )3\.5px'), r'\g<1>4px'),
 ('routine list 14 3->2.5', re.compile(r'(<span style="width: 14px; height: 14px; border-radius: 50%; background: '+C+r'; box-shadow: inset 0 0 0 )3px( '+C+r'; flex: none;">)'), r'\g<1>2.5px\g<2>'),
 ('Later today 14 3->2.5', re.compile(r'(<span aria-hidden="true" style="width: 14px; height: 14px; border-radius: 50%; background: '+C+r'; box-shadow: inset 0 0 0 )3px( '+C+r';">)'), r'\g<1>2.5px\g<2>'),
 ('Wind Down list 16 3->2.5', re.compile(r'(<span aria-hidden="true" style="width: 16px; height: 16px; border-radius: 50%; background: '+C+r'; box-shadow: inset 0 0 0 )3px( '+C+r';">)'), r'\g<1>2.5px\g<2>'),
]
if __name__=='__main__':
    log=collections.Counter()
    for f in sorted(glob.glob('w108/project/E-*.dc.html')):
        b=f.split('/')[-1][:-8]
        if 'G4-6' in b or b=='E-Responsive': continue
        s=open(f).read(); t=s
        for name,rx,rep in RULES:
            t,n=rx.subn(rep,t)
            if n: log[(b,name)]+=n
        if t!=s: open(f,'w').write(t)
    for k,v in sorted(log.items()): print(v,k)
