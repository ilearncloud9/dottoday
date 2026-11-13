"""Cleanup 7a and 7b (owner 2026-11-09, ED-204). 7a: Android Minimal Add input Manrope 600 19 -> 600 20. 7b: Android task title Roboto 500 22 -> Manrope 700 24/30 (Edit task title and Create task title field). Light and dark."""
import re, collections
log=collections.Counter()
def apply(b):
    p=f'w113/project/{b}.dc.html'; s=open(p).read(); t=s
    t,n=re.subn(r'(<input id="[^"]*" type="text" value="[^"]*" style="[^"]*font: )600 19px Manrope',r'\g<1>600 20px Manrope',t); log[(b,'7a input')]+=n
    t,n=re.subn(r'<span style="display: block; font: 500 22px Roboto, system-ui, sans-serif;">Deep work: roadmap</span>','<span style="display: block; font: 700 24px/30px Manrope, system-ui, sans-serif;">Deep work: roadmap</span>',t); log[(b,'7b edit title')]+=n
    def f(m):
        x=m.group(0).replace('font: 500 22px Roboto, system-ui, sans-serif','font: 700 24px/30px Manrope, system-ui, sans-serif')
        return x.replace('height: 24px; background: #11615C; vertical-align: -5px','height: 28px; background: #11615C; vertical-align: -6px').replace('height: 24px; background: #5BC4B8; vertical-align: -5px','height: 28px; background: #5BC4B8; vertical-align: -6px')
    t,n=re.subn(r'<span role="textbox" aria-label="Title" style="display: block; font: 500 22px Roboto, system-ui, sans-serif;[^"]*">(?:<span aria-hidden="true" style="[^"]*"></span>)?',f,t); log[(b,'7b title field')]+=n
    if t!=s: open(p,'w').write(t)
for b in ['E-PhonesMinimal','E-PhonesMinimal-Dark','E-Phones','E-Phones-Dark','E-Phones-3','E-Phones-3-Dark']: apply(b)
for k,v in sorted(log.items()):
    if v: print(v,k)
