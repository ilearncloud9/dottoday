"""Cleanup item 2, option A (owner 2026-11-08, ED-198): one light now-ring recipe. Light frames only; dark untouched.
Track = task's own colour at 20 %; arc = the family's ring token (teal #289588); cut-out 5 px phones / 4.5 px wide on thread now-dots."""
import re, sys, glob, collections; sys.path.insert(0,'h'); from bal import elem
FRAME=re.compile(r'<div( data-theme="dark")?\s+style="width:\d+px;height:\d+px;padding:8px')
def is_dark(s,pos,board):
    if board.endswith('-Dark'): return True
    m=None
    for m in FRAME.finditer(s,0,pos): pass
    return bool(m and m.group(1))
def fix(s,board,log):
    out=[]; i=0
    for m in re.finditer(r'conic-gradient\((#[0-9A-Fa-f]{6}) 0 (\d+)%, ?([^ ]+) (\2)% 100%\)',s):
        arc,p,track=m.group(1).upper(),m.group(2),m.group(3)
        if arc=='#11615C' or is_dark(s,m.start(),board): continue
        na,nt=arc,track
        if arc=='#5B5FD6' and track.upper()=='#E4E3F7': nt='rgba(91,95,214,.2)'
        if arc=='#2A9D8F': na='#289588'
        if arc=='#8B5CF6' and track=='rgba(91,95,214,.2)': nt='rgba(139,92,246,.2)'
        if arc=='#8B5CF6' and track.upper()=='#8B5CF640': nt='#8B5CF633'
        if arc=='#E45936' and track.upper()=='#E4593640': nt='#F0A28E33'
        if (na,nt)!=(arc,track):
            log[(board,arc+'/'+track,na+'/'+nt)]+=1
            out.append(s[i:m.start()]+f'conic-gradient({na} 0 {p}%, {nt} {p}% 100%)'); i=m.end()
    s=''.join(out)+s[i:]
    # cut-out: thread now-dots 34-40 px inside phone frames (390/412 wide) must be 5 px
    out=[]; i=0
    for m in re.finditer(r'<span style="width: (3[4-9]|40)px; height: \1px; border-radius: 50%; background: radial-gradient\(closest-side, #FFFDF9 calc\(100% - 4\.5px\), transparent calc\(100% - 4px\)\), conic-gradient',s):
        if is_dark(s,m.start(),board): continue
        roots=[r for r in re.finditer(r'<div style="position: relative; width: (\d+)px; height: (\d+)px;',s[:m.start()])]
        if not roots or roots[-1].group(1) not in ('390','412'): continue
        rep=m.group(0).replace('calc(100% - 4.5px), transparent calc(100% - 4px)','calc(100% - 5px), transparent calc(100% - 4.5px)')
        log[(board,'cut-out 4.5 on phone','5')]+=1
        out.append(s[i:m.start()]+rep); i=m.end()
    return ''.join(out)+s[i:]
if __name__=='__main__':
    log=collections.Counter()
    for f in sorted(glob.glob('w107/project/*.dc.html')):
        b=f.split('/')[-1][:-8]
        if b.endswith('-Dark') or not b.startswith('E-') or b in ('E-G4-6-Dark-Frames',): continue
        s=open(f).read(); t=fix(s,b,log)
        if t!=s: open(f,'w').write(t)
    for k,v in sorted(log.items()): print(v,k)
    print('total',sum(log.values()))
