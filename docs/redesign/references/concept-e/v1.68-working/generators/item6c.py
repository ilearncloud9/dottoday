"""Cleanup item 6c, option A (owner 2026-11-09, ED-202): Android Now card radius 22 -> 24 (heights 80 iPhone / 82 Android unchanged). Light and dark."""
import re, glob, collections
EXPECT={'E-Phones':1,'E-Phones-2':2,'E-Phones-Dark':1,'E-Phones-2-Dark':2,'E-G4-7-States':4,'E-G4-7-Q4-KeepBoth':2}
log={}
for b,n in EXPECT.items():
    p=f'w111/project/{b}.dc.html'; s=open(p).read(); k=0
    def f(m):
        global k
        st=m.group(1)
        if 'min-height: 82px' in st and re.search(r'border-radius: 22px',st):
            k+=1; return 'style="'+st.replace('border-radius: 22px','border-radius: 24px')+'"'
        return m.group(0)
    t=re.sub(r'style="([^"]*)"',f,s); log[b]=k
    assert k==n,(b,k,n)
    open(p,'w').write(t)
print(log)
