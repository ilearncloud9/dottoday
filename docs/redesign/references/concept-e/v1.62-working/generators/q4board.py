"""ED-195: G4-7 Q4 option B (Keep both, notes only) drawn on a linked board E-G4-7-Q4-KeepBoth (states board is at the 8000 px cap)."""
import re, sys, html; sys.path.insert(0,'h'); from bal import elem
SRC='w106/project/E-G4-7-States.dc.html'; OUT='w106/project/E-G4-7-Q4-KeepBoth.dc.html'
S=open(SRC).read()
def frames(lab):
    x=S.index(f'<section aria-label="{lab}'); e=elem(S,x); c=S[x:e]
    r=c.index('<div style="display:flex;gap:12px;align-items:flex-start">'); row=c[r:elem(c,r)]
    i=row.index('>')+1; out=[]
    while True:
        a=row.find('<div',i)
        if a<0: break
        b=elem(row,a); out.append(row[a:b]); i=b
    return out[:2]
def strip_sheet(f):
    a=f.find('<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(')
    if a<0: return f
    d=f.index('<div role="dialog"',a); e=elem(f,d); return f[:a]+f[e:]
def inject(f,html_):
    m=re.search(r'<div style="position: relative; width: \d+px; height: \d+px;',f); a=m.start(); e=elem(f,a)
    return f[:e-6]+html_+f[e-6:]
TK={'L':dict(sheet='#FFFDF9',card='#F6F1EA',box='#FFFDF9',ink='#241F2B',sec='#4E4757',bb='#FFFDF9',bs='inset 0 0 0 1px rgba(36,31,43,.16)',scrim='rgba(36,31,43,.32)',handle='#CFC6D6',acc='#11615C',sh='0 -8px 30px rgba(36,31,43,.16)',dis_b='#F1ECE4',dis_f='#6F6978',
          pop_mac='#F8F5FA',pop_web='#FFFDF9',psh='0 0 0 .5px rgba(0,0,0,.25), 0 12px 34px rgba(36,31,43,.22)',bg='#F3ECE2',frame='#E9E2D6',th='',kbd='#CFC6D6'),
    'D':dict(sheet='#28232A',card='#1F1B1E',box='#28232A',ink='#F3ECE4',sec='#C7BEC4',bb='#28232A',bs='inset 0 0 0 1px rgba(255,245,235,0.21)',scrim='rgba(0,0,0,0.60)',handle='#4A4348',acc='#5BC4B8',sh='0 -8px 30px rgba(0,0,0,0.35)',dis_b='#2F2A30',dis_f='#A0999F',
          pop_mac='#37313A',pop_web='#37313A',psh='0 0 0 .5px rgba(0,0,0,.25), 0 12px 34px rgba(0,0,0,.5)',bg='#171416',frame='#0E0C0E',th=' data-theme="dark"',kbd='#4A4348')}
MINE="Pull last quarter's notes first.\nThree themes, no more."
THEIRS="Ask Sam for the Q3 numbers.\nKeep it to three themes."
SEP='— From your other device —'
COMBINED=MINE+'\n\n'+SEP+'\n'+THEIRS
e_=lambda t: html.escape(t,quote=False)
def notebox(t,txt,k=1,label=None,extra=''):
    f=lambda px: f'{px*k:g}px'
    thumb=(f'<div aria-hidden="true" style="position:absolute;right:{f(3)};top:{f(6)};width:{f(4)};height:{f(40)};border-radius:2px;background:{t["sec"]};opacity:.55"></div>' if extra else '')
    return (f'<div role="group" aria-label="{label}" tabindex="{0 if extra else -1}" style="position:relative;border-radius:{f(12)};background:{t["box"]};box-shadow:{t["bs"]};padding:{f(9)} {f(14)} {f(9)} {f(12)};white-space:pre-wrap;font:500 {f(14)}/{f(20)} Manrope,system-ui;color:{t["ink"]};{extra}">{e_(txt)}{thumb}</div>')
def btn(t,label,k=1,android=False,disabled=False,full=True,hint=None):
    f=lambda px: f'{px*k:g}px'; h=48 if android else 44; r=20 if android else 22
    bg,fg=(t['dis_b'],t['dis_f']) if disabled else (t['bb'],t['ink'])
    d=' disabled aria-disabled="true"' if disabled else ''
    hd=f' aria-description="{hint}"' if hint else ''
    return f'<button{d}{hd} style="{"width:100%;" if full else ""}min-height:{h*k}px;padding:0 {f(20)};border:0;border-radius:{r*k}px;background:{bg};color:{fg};box-shadow:{"none" if disabled else t["bs"]};font:700 {f(15)} Manrope,system-ui">{label}</button>'
def copyb(t,who):
    return f'<button aria-label="Copy {who.lower()}\'s notes" style="margin:-12px -10px -12px 6px;min-height:44px;padding:0 10px;border:0;background:none;color:{t["acc"]};font:700 13px Manrope,system-ui">Copy</button>'
def conflict_card(t,field,mine,theirs,choices,k=1,android=False,limit=False):
    f=lambda px: f'{px*k:g}px'
    vals=(f'<div style="display:flex;flex-direction:column;gap:{f(6)}"><div style="display:flex;align-items:baseline"><span style="font:600 {f(13)} Manrope;color:{t["sec"]}">This device</span>'
          + (f'<span style="margin-left:auto;font:600 {f(12)} Manrope;color:{t["sec"]}">8,214 characters</span>{copyb(t,"This device")}' if limit else '') + '</div>'
          + notebox(t,mine,k,"This device's notes", 'max-height:%s;overflow:hidden;'%f(110) if limit else '')
          + f'</div><div style="display:flex;flex-direction:column;gap:{f(6)}"><div style="display:flex;align-items:baseline"><span style="font:600 {f(13)} Manrope;color:{t["sec"]}">Other device</span><span style="margin-left:auto;font:600 {f(12)} Manrope;color:{t["sec"]}">{"3,902 characters · " if limit else ""}in use now</span>{copyb(t,"Other device") if limit else ""}</div>'
          + notebox(t,theirs,k,"Other device's notes, in use now", 'max-height:%s;overflow:hidden;'%f(110) if limit else '') + '</div>') if field=='Notes' else (
          f'<div style="display:flex;gap:8px;align-items:baseline"><span style="flex:none;width:{f(96)};font:600 {f(13)} Manrope;color:{t["sec"]}">This device</span><span style="font:700 {f(15)} Manrope">{mine}</span></div>'
          f'<div style="display:flex;gap:8px;align-items:baseline"><span style="flex:none;width:{f(96)};font:600 {f(13)} Manrope;color:{t["sec"]}">Other device</span><span style="font:700 {f(15)} Manrope">{theirs}</span><span style="margin-left:auto;font:600 {f(12)} Manrope;color:{t["sec"]}">in use now</span></div>')
    return (f'<div style="border-radius:{f(20)};background:{t["card"]};padding:{f(14)} {f(16)};display:flex;flex-direction:column;gap:{f(10)}"><div style="font:800 {f(16)} Manrope,system-ui">Deep work: roadmap · {field}</div>{vals}{choices}</div>')
def stack(t,k=1,android=False,limit=False):
    f=lambda px: f'{px*k:g}px'
    kb=btn(t,'Keep both',k,android,disabled=limit,hint=None if limit else "Adds the other device's notes below yours")
    if limit: kb=kb.replace('<button disabled',f'<button aria-describedby="kb-why-{t["sheet"][1:]}" disabled',1)
    b=btn(t,'Keep mine',k,android)+btn(t,'Keep theirs',k,android)+kb
    note=(f'<div role="note" id="kb-why-{t["sheet"][1:]}" style="font:500 {f(13)}/{f(18)} Manrope;color:{t["ink"]}"><div style="font:800 {f(13.5)}/{f(18)} Manrope">Keep both isn\'t available</div>Together, these notes exceed the 10,000-character limit. You can copy either version before choosing which one to keep.</div>' if limit
          else f'<div style="font:500 {f(13)}/{f(18)} Manrope;color:{t["sec"]}">Keep both adds the other device\'s notes below yours.</div>')
    return f'<div style="display:flex;flex-direction:column;gap:{f(8)};margin-top:{f(2)}">{b}{note}</div>'
def ios_sheet(t,body,height=640):
    return (f'<div aria-hidden="true" style="position: absolute; inset: 0; background: {t["scrim"]}; z-index: 40;"></div>'
      f'<div role="dialog" aria-modal="true" aria-label="Changed on two devices" style="position: absolute; left: 0; right: 0; bottom: 0; height: {height}px; z-index: 41; border-radius: 34px 34px 0 0; background: {t["sheet"]}; box-shadow: {t["sh"]}; padding: 6px 20px 34px; box-sizing: border-box; font-family: Manrope, system-ui, sans-serif; color: {t["ink"]}; overflow: hidden;">'
      f'<div aria-hidden="true" style="width: 36px; height: 5px; border-radius: 3px; background: {t["handle"]}; margin: 6px auto 10px;"></div>'
      f'<div style="display: flex; align-items: center; justify-content: space-between;"><div style="font: 800 22px Manrope;">Changed on two devices</div><button style="height: 44px; padding: 0 6px; border: 0; background: none; color: {t["acc"]}; font: 700 16px -apple-system, system-ui;">Done</button></div>'
      f'<div style="margin: 4px 0 14px; font: 500 14px/20px Manrope; color: {t["sec"]};">The other device\'s change is in use until you choose.</div>{body}</div>')
XI='<svg class="i" width="22" height="22" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"></path></svg>'
def android_sheet(t,body,height=680):
    return (f'<div aria-hidden="true" style="position: absolute; inset: 0; background: {t["scrim"]}; z-index: 40;"></div>'
      f'<div role="dialog" aria-modal="true" aria-label="Changed on two devices" style="position: absolute; left: 0; right: 0; bottom: 0; height: {height}px; z-index: 41; border-radius: 28px 28px 0 0; background: {t["sheet"]}; box-shadow: {t["sh"]}; padding: 6px 20px 28px; box-sizing: border-box; font-family: Manrope, system-ui, sans-serif; color: {t["ink"]}; overflow: hidden;">'
      f'<div aria-hidden="true" style="width: 32px; height: 4px; border-radius: 2px; background: {t["handle"]}; margin: 16px auto 8px;"></div>'
      f'<div style="display: flex; align-items: center; gap: 4px;"><button aria-label="Close" style="width:48px;height:48px;margin-left:-12px;border:0;background:none;color:{t["ink"]};display:flex;align-items:center;justify-content:center">{XI}</button><div style="font: 800 22px Manrope;">Changed on two devices</div></div>'
      f'<div style="margin: 2px 0 14px; font: 500 14px/20px Manrope; color: {t["sec"]};">The other device\'s change is in use until you choose.</div>{body}</div>')
def task_sheet(t):
    return (f'<div aria-hidden="true" style="position: absolute; inset: 0; background: {t["scrim"]}; z-index: 40;"></div>'
      f'<div role="dialog" aria-modal="true" aria-label="Deep work: roadmap" style="position: absolute; left: 0; right: 0; bottom: 0; height: 600px; z-index: 41; border-radius: 34px 34px 0 0; background: {t["sheet"]}; box-shadow: {t["sh"]}; padding: 6px 20px 34px; box-sizing: border-box; font-family: Manrope, system-ui, sans-serif; color: {t["ink"]}; overflow: hidden; display:flex; flex-direction:column; gap:12px">'
      f'<div aria-hidden="true" style="width: 36px; height: 5px; border-radius: 3px; background: {t["handle"]}; margin: 6px auto 0;"></div>'
      f'<div style="display: flex; align-items: center; justify-content: space-between;"><div style="font: 800 22px Manrope;">Deep work: roadmap</div><button style="height: 44px; padding: 0 6px; border: 0; background: none; color: {t["acc"]}; font: 700 16px -apple-system, system-ui;">Done</button></div>'
      f'<div class="num" style="font: 600 14px Manrope; color: {t["sec"]}; margin-top:-8px">9:00–11:00 AM · Tue 3 Nov</div>'
      f'<label style="font: 700 13px Manrope; margin-top:6px">Notes</label>'
      f'<div role="textbox" aria-multiline="true" aria-label="Notes" style="border-radius:14px;background:{t["card"]};padding:12px 14px;white-space:pre-wrap;font:500 15px/22px Manrope,system-ui;color:{t["ink"]}">{e_(COMBINED)}</div>'
      f'<div style="font:500 13px/18px Manrope;color:{t["sec"]}">Plain text: the line "{SEP}" is part of the note and can be edited or deleted like any other text.</div></div>')
def mini(t,plat,body,W=440,H=430):
    mac=plat=='Mac'; ff='-apple-system, system-ui, sans-serif' if mac else 'Manrope, system-ui'
    pop=t['pop_mac'] if mac else t['pop_web']; r='12px' if mac else '14px'
    return (f'<div{t["th"]} style="width:{W}px;height:{H}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{t["frame"]};flex:none">'
      f'<div style="position:relative;width:100%;height:100%;border-radius:10px;background:{t["bg"]};overflow:hidden">'
      f'<div role="dialog" aria-label="Sync" style="position:absolute;left:10px;right:10px;top:10px;border-radius:{r};background:{pop};box-shadow:{t["psh"]};padding:12px 14px 14px;font-family:{ff};color:{t["ink"]};display:flex;flex-direction:column;gap:9px">{body(t,mac,ff)}</div></div></div>')
def desk_conflict(t,mac,ff):
    br='7px' if mac else '16px'; h=28 if mac else 36
    b=lambda l,hint='': f'<button{hint} style="min-height:{h}px;padding:0 14px;border:0;border-radius:{br};background:{t["bb"]};color:{t["ink"]};box-shadow:{t["bs"]};font:700 13px {ff}">{l}</button>'
    vals=(f'<div style="font:600 12px Manrope;color:{t["sec"]}">This device</div>'+notebox(t,MINE,0.93,"This device's notes")+
          f'<div style="display:flex;font:600 12px Manrope;color:{t["sec"]}"><span>Other device</span><span style="margin-left:auto">in use now</span></div>'+notebox(t,THEIRS,0.93,"Other device's notes, in use now"))
    return (f'<div style="font:700 13px {ff}">Changed on two devices</div><div style="font:12px {ff};color:{t["sec"]}">The other device\'s change is in use until you choose.</div>'
            f'<div style="border-radius:16px;background:{t["card"]};padding:12px 14px;display:flex;flex-direction:column;gap:6px"><div style="font:800 15px Manrope,system-ui">Deep work: roadmap · Notes</div>{vals}'
            f'<div role="group" aria-label="Choose notes" style="display:flex;gap:8px;margin-top:6px">{b("Keep mine")}{b("Keep theirs")}{b("Keep both"," aria-description=\"Adds the other device&#39;s notes below yours\"")}</div>'
            f'<div style="font:500 12px/16px Manrope;color:{t["sec"]}">Keep both adds the other device\'s notes below yours.</div></div>')
CHECK='<svg class="i" width="16" height="16" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12.5l4.5 4.5L19 7.5"></path></svg>'
def desk_undo(t,mac,ff):
    key='⌘Z' if mac else 'Ctrl+Z'; br='7px' if mac else '16px'
    return (f'<div style="font:700 13px {ff}">Sync</div><div role="status" style="display:flex;gap:8px;align-items:flex-start"><span style="display:flex">{CHECK}</span><div><div style="font:600 13px/17px {ff}">Kept both versions of the notes</div><div style="font:500 12px/16px {ff};color:{t["sec"]}">Deep work: roadmap · Notes</div></div></div>'
            f'<div><button aria-label="Undo: keep only this device\'s notes" style="min-height:{28 if mac else 32}px;padding:0 12px;border:0;border-radius:{br};background:{t["bb"]};box-shadow:{t["bs"]};color:{t["ink"]};font:700 13px {ff};display:flex;align-items:center;gap:8px">Undo<kbd style="font:600 11px {ff};color:{t["sec"]};padding:0 5px;border-radius:4px;box-shadow:inset 0 0 0 1px {t["kbd"]}">{key}</kbd></button></div>')
def big200(t):
    k=2
    body=(f'<div style="flex:1;min-height:0;overflow:hidden;display:flex;flex-direction:column;gap:20px">'
          f'<div style="font:800 40px/48px Manrope">Changed on two devices</div>'
          + conflict_card(t,'Notes',MINE,THEIRS,'',k) + '</div>'
          f'<div style="flex:none;padding-top:14px;box-shadow:0 -1px 0 {t["handle"]};display:flex;flex-direction:column;gap:12px">{btn(t,"Keep mine",k)}{btn(t,"Keep theirs",k)}{btn(t,"Keep both",k,hint="Adds the other device&#39;s notes below yours")}</div>')
    return (f'<div aria-hidden="true" style="position: absolute; inset: 0; background: {t["scrim"]}; z-index: 40;"></div>'
      f'<div role="dialog" aria-modal="true" aria-label="Changed on two devices" style="position: absolute; left: 0; right: 0; bottom: 0; top: 54px; z-index: 41; border-radius: 34px 34px 0 0; background: {t["sheet"]}; padding: 20px 20px 34px; box-sizing: border-box; font-family: Manrope, system-ui; color: {t["ink"]}; overflow: hidden; display:flex; flex-direction:column">{body}'
      f'<div aria-hidden="true" style="position:absolute;right:6px;top:120px;width:5px;height:260px;border-radius:3px;background:{t["sec"]};opacity:.55"></div></div>')

TAG='Q4 approved (ED-195) · design only · not built'
def section(aria,title,text,fr,w,tag=TAG,labels=None):
    labels=labels or ['Light','Dark · P1']
    heads=''.join(f'<div style="font:700 13px Manrope;color:#6A6273;width:{w}px">{l}</div>' for l in labels)
    return (f'<section aria-label="{aria}" style="display:flex;flex-direction:column;gap:8px"><div style="display:flex;gap:12px">{heads}</div>'
            f'<div style="display:flex;gap:12px;align-items:flex-start">{"".join(fr)}</div><div style="font:500 14px/20px Manrope;color:#4E4757;width:{len(labels)*w+12*(len(labels)-1)}px"><div style="font:800 17px Manrope;color:#241F2B">{title}</div><div>{text}</div><span class="th" style="margin-top:6px">{tag}</span></div></section>')

def run():
    ip=[strip_sheet(f) for f in frames('C2')]; an=frames('B3'); c3=frames('C3')
    L,D=TK['L'],TK['D']
    q4a=[inject(ip[0],ios_sheet(L,conflict_card(L,'Notes',MINE,THEIRS,stack(L)),660)),inject(ip[1],ios_sheet(D,conflict_card(D,'Notes',MINE,THEIRS,stack(D)),660))]
    q4b=[inject(an[0],android_sheet(L,conflict_card(L,'Notes',MINE,THEIRS,stack(L,android=True),android=True),720)),inject(an[1],android_sheet(D,conflict_card(D,'Notes',MINE,THEIRS,stack(D,android=True),android=True),720))]
    q4c=[mini(L,'Mac',desk_conflict),mini(D,'Mac',desk_conflict)]
    q4d=[mini(L,'Web',desk_conflict),mini(D,'Web',desk_conflict)]
    q4e=[inject(ip[0],task_sheet(L)),inject(ip[1],task_sheet(D))]
    q4f=[]
    for f in c3:
        f2=f.replace(">Kept this device's time<button",">Kept both versions of the notes<button").replace('aria-label="Undo: go back to the other device\'s time"','aria-label="Undo: keep only this device\'s notes"')
        assert f2!=f; q4f.append(f2)
    q4f2=[mini(T,p,desk_undo,320,170) for p in ['Mac','Web'] for T in [L,D]]
    two=lambda t: f'<div style="display:flex;gap:10px;margin-top:4px">{btn(t,"Keep mine",full=False)}{btn(t,"Keep theirs",full=False)}</div>'
    q4g=[inject(ip[0],ios_sheet(L,conflict_card(L,'Title','Deep work: roadmap','Roadmap draft',two(L)),420)),inject(ip[1],ios_sheet(D,conflict_card(D,'Title','Deep work: roadmap','Roadmap draft',two(D)),420))]
    q4h=[inject(ip[0],big200(L)),inject(ip[1],big200(D))]
    LM="Pull last quarter's notes first.\nThree themes, no more.\nRoadmap principles: start from what customers asked for most in Q3."
    LT="Ask Sam for the Q3 numbers.\nKeep it to three themes.\nDraft outline: 1. Reliability, 2. Planning, 3. Sharing."
    q4i=[inject(ip[0],ios_sheet(L,conflict_card(L,'Notes',LM,LT,stack(L,limit=True),limit=True),700)),inject(ip[1],ios_sheet(D,conflict_card(D,'Notes',LM,LT,stack(D,limit=True),limit=True),700))]
    row1=(section('Q4a iPhone · notes conflict · three choices','Q4a · iPhone · notes conflict · three choices','Both versions in full. Keep mine, Keep theirs, Keep both stacked with equal weight (no squeezing); a one-line hint says what Keep both does.',q4a,320)
         +section('Q4b Android · notes conflict · three choices','Q4b · Android · notes conflict · three choices','Same card in the Android bottom sheet: Close at the start, 48 dp buttons, stacked.',q4b,320)
         +section('Q4c Mac · Sync popover · three choices','Q4c · Mac · Sync popover · three choices','The C4 journey for notes: three buttons in a row; Tab moves Keep mine → Keep theirs → Keep both, Return chooses.',q4c,440)
         +section('Q4d Web · Sync popover · three choices','Q4d · Web · Sync popover · three choices','Same on web; at narrow widths and 200 % the buttons stack.',q4d,440))
    row2=(section('Q4e iPhone · combined note','Q4e · Combined note after Keep both','This device\'s notes first, a blank line, the label line, then the other device\'s notes. Line breaks kept; nothing removed or reordered. No time or device name (the app does not store them).',q4e,320)
         +section('Q4f iPhone · Undo after Keep both','Q4f · iPhone · Undo after Keep both (Q3)','The approved Q3 confirmation. Undo puts back this device\'s notes, only if the note has not changed since.',q4f,320)
         +section('Q4f2 Mac and web · Undo after Keep both','Q4f · Mac and web · Undo after Keep both (Q3)','⌘Z / Ctrl+Z only when this Undo applies and no text field has focus.',q4f2,320,labels=['Mac · Light','Mac · Dark · P1','Web · Light','Web · Dark · P1']))
    row3=(section('Q4g iPhone · title conflict · two choices','Q4g · Title conflict keeps two choices','Titles never get Keep both and never create a second task.',q4g,320)
         +section('Q4h iPhone · notes conflict · 200 % text','Q4h · Notes conflict · 200 % text','Full-height sheet; both versions scroll; the three choices stay stacked and reachable at the bottom.',q4h,320)
         +section('Q4i iPhone · notes too long to keep both','Q4i · Keep both unavailable: together over 10,000 characters','Approved (Q4-L1): Keep both is disabled when the whole combined note (both notes, the blank line, the label line and every line break) would pass 10,000 as the app validator counts. Both versions stay readable, scrollable and copyable; Keep mine and Keep theirs stay available; nothing is trimmed, resolved or claimed saved.',q4i,320,tag='Q4-L1 approved (ED-196) · design only · not built'))
    notes=('<div style="width:1080px;box-sizing:border-box;border-radius:18px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.10);padding:18px 22px;font:500 14px/20px Manrope;color:#4E4757;display:flex;flex-direction:column;gap:6px">'
     '<div style="font:800 18px Manrope;color:#241F2B">Q4 · rules (ED-195)</div>'
     '<div><b>Scope:</b> Keep both for notes only. Titles, dates, times, routines, colours and settings keep Keep mine / Keep theirs.</div>'
     '<div><b>Format:</b> notes are plain text up to 10,000 characters (app and server); conflicts store only the two values and when the conflict was found. Combined text = this device\'s notes, a blank line, "— From your other device —", the other device\'s notes. No schema change.</div>'
     '<div><b>Saving:</b> one ordinary notes edit through the normal save and sync; applied once on repeated taps or retries; if either version changed before the save, back to conflict review; offline or failed save keeps both versions and shows the existing "Couldn\'t save"; success only after the save.</div>'
     '<div><b>Undo (Q3):</b> restores this device\'s notes only if the note is unchanged since; otherwise conflict review. No other field changes.</div>'
     '<div><b>Accessibility:</b> each version is a labelled group read in full ("This device\'s notes", "Other device\'s notes, in use now"); Keep both hint "Adds the other device\'s notes below yours"; focus order Keep mine, Keep theirs, Keep both; stacked on phones and at 200 %.</div>'
     '<div><b>Limit (Q4-L1, ED-196):</b> Keep both is disabled with "Keep both isn\'t available" when the full combined text is over 10,000 counted as Dart <code>String.length</code> (UTF-16 units), the strictest of the app validator, SQLite <code>length()</code> and Postgres <code>char_length</code> (code points); each version has Copy; no trimming.</div>'
     '<div><b>Ownership:</b> CR-160 isolation applies; not verified yet.</div></div>')
    page=(f'<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · G4-7 Q4 Keep both</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n<helmet>'
          + S[S.index('<link rel="preconnect"'):S.index('</helmet>')] + '</helmet>\n'
          '<div style="width: 3600px; height: 2720px; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 40px; overflow: hidden;">'
          '<header><h1 style="margin:0;font-size:38px;line-height:44px;font-weight:700;letter-spacing:-0.6px">G4-7 Q4 · Keep both for notes · approved design (ED-195) · not built, not merged</h1>'
          '<p style="margin:8px 0 0;font-size:18px;color:#4E4757;max-width:3400px">Linked to E-G4-7-States (section C, conflict journey), which is at the 8000 px board limit. Option B: notes get Keep mine / Keep theirs / Keep both; titles keep two choices. Each frame in light and dark (P1).</p></header>'
          f'<div style="display:flex;gap:40px;align-items:flex-start">{row1}</div>'
          f'<div style="display:flex;gap:40px;align-items:flex-start">{row2}</div>'
          f'<div style="display:flex;gap:40px;align-items:flex-start">{row3}{notes}</div>'
          '</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":3600,"height":2720}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body></html>\n')
    open(OUT,'w').write(page); print('ok',len(page))
if __name__=='__main__': run()
