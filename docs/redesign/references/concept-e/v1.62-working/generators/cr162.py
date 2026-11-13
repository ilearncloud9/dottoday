"""CR-162 (owner approved 2026-11-08, ED-196): in dark, the glyph (type icon or done check) inside an amber #D9A23A dot uses ink #171416 (8.0:1).
Only spans that contain an <svg>; empty dots and light frames untouched; E-G4-6-Dark-Frames kept as history."""
import re, sys, glob; sys.path.insert(0,'h'); from bal import elem
PAT=re.compile(r'background: ?#D9A23A; ?color: ?#F3ECE4')
def fix(s):
    out=[]; i=0; n=0; odd=[]
    for m in PAT.finditer(s):
        a=s.rfind('<',0,m.start()); e=elem(s,a); el=s[a:e]
        if '<svg' not in el: continue
        inner=el[el.index('>')+1:]
        if re.search(r'(stroke|fill|color)[=:]\s*"?#(?!171416)[0-9A-Fa-f]{6}',inner): odd.append(inner[:120])
        out.append(s[i:m.start()]+m.group(0).replace('#F3ECE4','#171416')); i=m.end(); n+=1
    return ''.join(out)+s[i:], n, odd
if __name__=='__main__':
    tot=0
    for f in sorted(glob.glob('w106/project/*.dc.html')):
        if 'G4-6-Dark-Frames' in f: continue
        s=open(f).read(); t,n,odd=fix(s)
        if n: open(f,'w').write(t); print(f.split('/')[-1],n, 'ODD:'+str(odd[:2]) if odd else ''); tot+=n
    print('total',tot)
