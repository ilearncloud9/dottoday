"""Cleanup item 4, option A (owner 2026-11-09, ED-200): calendar-event dots. Centre = the surface behind; ring 2.5 px standard, 2 px for dots <= 16 px. Light and dark."""
import re, glob, collections
def edit_styles(s, cond, change):
    n=0
    def f(m):
        nonlocal n
        st=m.group(1)
        if cond(st):
            st2=change(st)
            if st2!=st: n+=1; return 'style="'+st2+'"'
        return m.group(0)
    return re.sub(r'style="([^"]*)"',f,s), n
W=lambda st,w: re.search(r'(?:^|[; ])width: ?%spx'%w, st) is not None
RULES=[
 ('light 14 white centre -> #FBF7F1', lambda st: W(st,14) and 'background: #FFFFFF' in st and 'inset 0 0 0 2px #7A7280' in st, lambda st: st.replace('background: #FFFFFF','background: #FBF7F1')),
 ('light block centre -> #F6F1EA', lambda st: (W(st,28) or W(st,32)) and 'background: #FFFDF9' in st and 'inset 0 0 0 2.5px #7A7280' in st, lambda st: st.replace('background: #FFFDF9','background: #F6F1EA')),
 ('dark block centre -> #1F1B1E', lambda st: (W(st,28) or W(st,32)) and 'background: #28232A' in st and 'inset 0 0 0 2.5px #8C838A' in st, lambda st: st.replace('background: #28232A','background: #1F1B1E')),
 ('12 px preview ring 2.5 -> 2', lambda st: W(st,12) and re.search(r'inset 0 0 0 2\.5px #(7A7280|8C838A)',st) is not None, lambda st: re.sub(r'inset 0 0 0 2\.5px #(7A7280|8C838A)',r'inset 0 0 0 2px #\1',st)),
]
if __name__=='__main__':
    log=collections.Counter()
    for b in ['E-Minimal','E-FullA-v2','E-G4-3-Narrow','E-G4-7-States','E-PhonesMinimal','E-FullA-v2-Dark','E-G4-3-Narrow-Dark','E-PhonesMinimal-Dark','E-Minimal-Dark']:
        p=f'w109/project/{b}.dc.html'; s=open(p).read(); t=s
        for name,c,ch in RULES:
            t,n=edit_styles(t,c,ch)
            if n: log[(b,name)]+=n
        if t!=s: open(p,'w').write(t)
    for k,v in sorted(log.items()): print(v,k)
