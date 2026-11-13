"""ED-194: G4-7 Q3 option A approved (owner 2026-11-08). C3 Undo becomes the approved design; C5 adds the Mac/web Sync popover confirmation with Undo. E-Map G4-7 lines updated."""
import re, sys; sys.path.insert(0,'h'); from bal import elem
P='w103/project/E-G4-7-States.dc.html'; M='w103/project/E-Map.dc.html'
s=open(P).read()
def rep(a,b,n=1):
    global s
    c=s.count(a); assert c==n,(a[:70],c); s=s.replace(a,b)
# C3: remove proposal labels and dashed outline
s,k=re.subn(r'<div aria-hidden="true" style="position: absolute; left: 16px; right: 16px; bottom: 156px;[^>]*>Undo: Q3 proposal · not built · not approved</div>','',s); assert k==2
rep('outline: 1.5px dashed currentColor; outline-offset: -5px; ','',2)
# accessible name for Undo in the toast
rep('>Undo</button></div>','>Undo</button></div>',2)
s=s.replace('font: 700 14px Manrope, system-ui;">Undo</button>','font: 700 14px Manrope, system-ui;" aria-label="Undo: go back to the other device\'s time">Undo</button>')
rep('Banner and badge clear. The toast says what was kept. Undo is a Q3 proposal only: not built and not approved. The app has no Undo here today.',
    'Banner and badge clear. The toast says what was kept, with Undo for about 10 s (Q3 approved, ED-194; not built). No timer shown. Rules in C5.')
x=s.index('<section aria-label="C3'); e=elem(s,x)
c=s[x:e].replace('<span class="th" style="margin-top:6px">Q1 direction approved · not merged</span>','<span class="th" style="margin-top:6px">Q3 approved (ED-194) · not built · not merged</span>'); s=s[:x]+c+s[e:]
rep('<b>Q3 · Undo after resolving a conflict</b> (open; not built, not approved): the app has none. Recommended: add Undo to the toast for 10 s (it re-applies the value you replaced).',
    '<b>Q3 · Undo after resolving a conflict · option A approved 2026-11-08 (ED-194)</b>: Undo in the confirmation for about 10 s; it saves the replaced value as a new edit. Design only; not built (C3, C5).')
rep('Decisions: Q1 and Q2 closed at design level; Q3 to Q5 open','Decisions: Q1, Q2 and Q3 closed at design level; Q4 and Q5 open')

# C5 mini frames: Mac and web popover confirmation, light and dark
T={'L':dict(bg='#F3ECE2',pop='#F8F5FA',popw='#FFFDF9',ink='#241F2B',sec='#4E4757',sh='0 0 0 .5px rgba(0,0,0,.25), 0 8px 24px rgba(36,31,43,.20)',btn='#FFFDF9',bs='inset 0 0 0 1px rgba(36,31,43,.16)',kbd='#CFC6D6',frame='#E9E2D6',th=''),
   'D':dict(bg='#171416',pop='#37313A',popw='#37313A',ink='#F3ECE4',sec='#C7BEC4',sh='0 0 0 .5px rgba(0,0,0,.25), 0 8px 24px rgba(0,0,0,.5)',btn='#28232A',bs='inset 0 0 0 1px rgba(255,245,235,0.21)',kbd='#4A4348',frame='#0E0C0E',th=' data-theme="dark"')}
CHECK='<svg class="i" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12.5l4.5 4.5L19 7.5"></path></svg>'
X='<svg class="i" width="13" height="13" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"></path></svg>'
def mini(t,plat):
    mac=plat=='Mac'; ff='-apple-system, system-ui, sans-serif' if mac else 'Manrope, system-ui'; key='⌘Z' if mac else 'Ctrl+Z'
    pop=t['pop'] if mac else t['popw']; r='12px' if mac else '14px'; br='7px' if mac else '16px'
    return (f'<div{t["th"]} style="width:320px;height:150px;padding:8px;box-sizing:border-box;border-radius:14px;background:{t["frame"]};flex:none">'
      f'<div style="position:relative;width:100%;height:100%;border-radius:10px;background:{t["bg"]};overflow:hidden">'
      f'<div role="dialog" aria-label="Sync" style="position:absolute;left:8px;right:8px;top:8px;border-radius:{r};background:{pop};box-shadow:{t["sh"]};padding:10px 12px 12px;font-family:{ff};color:{t["ink"]};display:flex;flex-direction:column;gap:8px">'
      f'<div style="display:flex;align-items:center"><div style="flex:1;font:700 13px {ff}">Sync</div><button aria-label="Close" style="width:24px;height:24px;border:0;background:none;color:{t["sec"]};display:flex;align-items:center;justify-content:center">{X}</button></div>'
      f'<div role="status" style="display:flex;gap:8px;align-items:flex-start"><span style="color:{t["ink"]};display:flex">{CHECK}</span><div><div style="font:600 13px/17px {ff}">Kept this device\'s time</div><div style="font:500 12px/16px {ff};color:{t["sec"]}">Deep work: roadmap · Time</div></div></div>'
      f'<div style="display:flex;align-items:center;gap:8px"><button aria-keyshortcuts="{"Meta+Z" if mac else "Control+Z"}" style="min-height:{28 if mac else 32}px;padding:0 12px;border:0;border-radius:{br};background:{t["btn"]};box-shadow:{t["bs"]};color:{t["ink"]};font:700 13px {ff};display:flex;align-items:center;gap:8px">Undo<kbd style="font:600 11px {ff};color:{t["sec"]};padding:0 5px;border-radius:4px;box-shadow:inset 0 0 0 1px {t["kbd"]}">{key}</kbd></button></div>'
      f'</div></div></div>')
frames=''.join(mini(T[th],pl) for pl in ['Mac','Web'] for th in ['L','D'])
C5=('<section aria-label="C5 Mac and web · resolved with Undo" style="display:flex;flex-direction:column;gap:8px">'
 '<div style="display:flex;gap:12px"><div style="font:700 13px Manrope;color:#6A6273;width:320px">Mac · Light</div><div style="font:700 13px Manrope;color:#6A6273;width:320px">Mac · Dark · P1</div><div style="font:700 13px Manrope;color:#6A6273;width:320px">Web · Light</div><div style="font:700 13px Manrope;color:#6A6273;width:320px">Web · Dark · P1</div></div>'
 f'<div style="display:flex;gap:12px">{frames}</div>'
 '<div style="font:500 13px/18px Manrope;color:#4E4757;width:1316px"><div style="font:800 16px Manrope;color:#241F2B">C5 · Mac and web · resolved, with Undo in the Sync popover</div>'
 '<div>After Keep mine / Keep theirs the popover shows what was kept and Undo for about 10 s; ⌘Z (Mac) or Ctrl+Z (web) works only when Undo applies and no text field or other Undo has focus. Pauses while focused or hovered; stays while VoiceOver or TalkBack is on; Close, Escape or a swipe dismisses. No visible countdown, no animation (Reduced Motion). Undo saves the replaced value as a new edit; a newer change elsewhere opens a new conflict instead.</div>'
 '<span class="th" style="margin-top:6px">Q3 approved (ED-194) · not built · not merged</span></div></section>')
x=s.index('<section aria-label="C4'); e=elem(s,x)
s=s[:x]+'<div style="display:flex;flex-direction:column;gap:22px">'+s[x:e]+C5+'</div>'+s[e:]
open(P,'w').write(s)
m=open(M).read()
a='G4-7 shared states and accessibility: option A approved (ED-186); kit drawn on E-G4-7-States in light and dark for review, not merged. Questions Q1–Q5 on that board.'
assert m.count(a)==1
m=m.replace(a,'G4-7 shared states and accessibility: option A (ED-186); on E-G4-7-States, light and dark, not merged. Q1 look (ED-187), Q2 web storage (ED-188 to ED-193) and Q3 conflict Undo (ED-194) closed at design level; not built. Q4 and Q5 open.')
b='Still open: G4-7 kit approval (next);'
assert m.count(b)==1
m=m.replace(b,'Still open: G4-7 Q4 and Q5 (next); CR-160 critical release blocker (implementation);')
open(M,'w').write(m); print('ok')
