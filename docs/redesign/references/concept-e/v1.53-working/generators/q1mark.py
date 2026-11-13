"""ED-187: owner approved G4-7 Q1 (direction only, 2026-11-08). Board labels updated; Undo stays a Q3 proposal, marked not built and not approved."""
p='w97/project/E-G4-7-States.dc.html'
s=open(p).read()
def rep(a,b,n=1):
    global s
    c=s.count(a); assert c==n,(a[:60],c); s=s.replace(a,b)
rep('· for your review (not merged)</h1>','· Q1 direction approved (ED-187) · not merged</h1>')
rep('Approved direction: option A (ED-186).','Approved: option A (ED-186) and the kit\'s look and one state system across platforms, with native variations (Q1, ED-187, direction only).')
rep('Decisions for you (nothing below is merged)','Decisions: Q1 approved; Q2 to Q5 open (nothing below is merged)')
rep("<b>Q1 · Approve the kit's look</b> (this board): loading, empty, errors, sync status, conflict journey, accessibility frames.",
    "<b>Q1 · The kit's look · approved 2026-11-08 (ED-187)</b>: direction only; one Concept E state system for loading, empty, errors, offline, sync status and conflict recovery, with native platform variations. Q2 to Q5 are not part of it.")
rep('<b>Q3 · Undo after resolving a conflict</b>: the app has none.','<b>Q3 · Undo after resolving a conflict</b> (open; not built, not approved): the app has none.')
n=s.count('Proposal · G4-7 kit · not merged'); s=s.replace('Proposal · G4-7 kit · not merged','Q1 direction approved · not merged')
rep('Undo is drawn as proposed (decision Q3); the app has no Undo here today.','Undo is a Q3 proposal only: not built and not approved. The app has no Undo here today.')
TAG=('<div aria-hidden="true" style="position: absolute; left: 16px; right: 16px; bottom: 156px; z-index: 31; border-radius: 10px; border: 1.5px dashed {b}; background: {bg}; color: {c}; '
     'padding: 5px 10px; font: 700 12px/16px Manrope, system-ui; text-align: center;">Undo: Q3 proposal · not built · not approved</div>')
for col,b,bg,c in [('#A3E2D9','#6E6A75','#FFFDF9','#241F2B'),('#0B4642','#8C838A','#2F2A30','#F3ECE4')]:
    old=f'<div role="status" aria-live="polite" style="position: absolute; left: 16px; right: 16px; bottom: 100px;'
    btn=f'color: {col}; font: 700 14px Manrope, system-ui;">Undo</button>'
    i=s.index(btn); j=s.rfind(old,0,i)
    s=s[:i]+btn.replace('font: 700','outline: 1.5px dashed currentColor; outline-offset: -5px; font: 700')+s[i+len(btn):]
    s=s[:j]+TAG.format(b=b,bg=bg,c=c)+s[j:]
open(p,'w').write(s); print('tags',n)
