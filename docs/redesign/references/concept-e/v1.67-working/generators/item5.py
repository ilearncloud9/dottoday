"""Cleanup item 5, option A (owner 2026-11-09, ED-201): Wake Up / Wind Down THREAD caps 34 px with 19 px icons (were 32 / 18). Light and dark.
Matched by structure: cap centred in the thread column (48 px phones / 44 px wide) and followed by its 'Wake Up ·' / 'Wind Down ·' label."""
import re, glob, collections
PAT=re.compile(r'(<span style="position: relative; width: (?:48|44)px; display: flex; justify-content: center;"><span (?:aria-hidden="true" )?style="width: )32px; height: 32px;( border-radius: 50%; background: #[0-9A-Fa-f]{6}; color: #[0-9A-Fa-f]{6}; display: flex; align-items: center; justify-content: center;"><svg class="i" width=")18" height="18"')
if __name__=='__main__':
    log=collections.Counter()
    for f in sorted(glob.glob('w110/project/E-*.dc.html')):
        b=f.split('/')[-1][:-8]
        if 'G4-6' in b: continue
        s=open(f).read(); out=[]; i=0
        for m in PAT.finditer(s):
            after=re.sub(r'<[^>]+>','',s[m.end():m.end()+900])
            k=re.search(r'(Wake Up|Wind Down) ·',after)
            if not k: continue
            log[(b,k.group(1))]+=1
            out.append(s[i:m.start()]+m.group(1)+'34px; height: 34px;'+m.group(2)+'19" height="19"'); i=m.end()
        t=''.join(out)+s[i:]
        if t!=s: open(f,'w').write(t)
    for k,v in sorted(log.items()): print(v,k)
    print('total',sum(log.values()))
