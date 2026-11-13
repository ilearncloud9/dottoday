"""G3-C1 comparison (cleanup 7a, 7b; owner approved drawing only, 2026-11-09, ED-203). Review board, no active board changed."""
import re, sys; sys.path.insert(0,'h'); from bal import elem
P='w112/project/'
def roots(b):
    s=open(P+b+'.dc.html').read(); return s,[(m.start(),elem(s,m.start())) for m in re.finditer(r'<div style="position: relative; width: (?:390|412)px; height: \d+px;',s)]
def root(b,i):
    s,f=roots(b); x,y=f[i]; return s[x:y]
LONG_T="Draft the Q1 roadmap themes with Sam before Thursday's planning review"
LONG_A="Draft roadmap themes with Sam Thu 4pm 1h"
def s1(html,dark,prop,k,text):
    sz=(20 if prop else 19)*k
    html=re.sub(r'(<input id="apm-and-add" type="text" value=")[^"]*(" style="[^"]*?font: )600 19px Manrope',lambda m: m.group(1)+text+m.group(2)+f'600 {sz:g}px Manrope',html,count=1)
    assert f'600 {sz:g}px Manrope' in html; return html
def s2(html,dark,prop,k,text):
    old='<span style="display: block; font: 500 22px Roboto, system-ui, sans-serif;">Deep work: roadmap</span>'
    assert old in html,'s2'
    f=(f'700 {24*k:g}px/{30*k:g}px Manrope, system-ui, sans-serif' if prop else f'500 {22*k:g}px Roboto, system-ui, sans-serif')
    return html.replace(old,f'<span style="display: block; font: {f}; overflow-wrap: anywhere;">{text}</span>',1)
def s3(html,dark,prop,k,text):
    m=re.search(r'<span role="textbox" aria-label="Title" style="display: block; font: 500 22px Roboto, system-ui, sans-serif; color: (#[0-9A-F]{6});">(<span aria-hidden="true" style="[^"]*"></span>)What is it\?</span>',html)
    assert m,'s3'
    f=(f'700 {24*k:g}px/{30*k:g}px Manrope, system-ui, sans-serif' if prop else f'500 {22*k:g}px Roboto, system-ui, sans-serif')
    cur=m.group(2).replace('height: 24px',f'height: {round((30 if prop else 24)*k)}px')
    if text is None:
        col=m.group(1); body=cur+'What is it?'
    else:
        col='#F3ECE4' if dark else '#241F2B'; body=text+cur
    return html[:m.start()]+f'<span role="textbox" aria-label="Title" style="display: block; font: {f}; color: {col}; overflow-wrap: anywhere;">{body}</span>'+html[m.end():]
Z=0.6
def frame(rhtml,dark,w):
    bg='#0E0C0E' if dark else '#E9E2D6'; fg='#F3ECE4' if dark else '#241F2B'; th=' data-theme="dark"' if dark else ''
    W=int(w*Z)+16; H=int(892*Z)+16
    return f'<div{th} style="width:{W}px;height:{H}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{bg};color:{fg};overflow:hidden;flex:none"><div style="zoom:{Z}">{rhtml}</div></div>'
def pair(lbl,cur,prop,curlab,proplab,w):
    return (f'<div style="display:flex;flex-direction:column;gap:6px"><div style="display:flex;gap:8px">'
            f'<div style="width:{int(w*Z)+16}px;font:700 12px/16px Manrope;color:#4E4757">Current · {curlab}</div><div style="width:{int(w*Z)+16}px;font:700 12px/16px Manrope;color:#0B4642">Proposed · {proplab}</div></div>'
            f'<div style="display:flex;gap:8px">{cur}{prop}</div><div style="font:600 13px/18px Manrope;color:#241F2B">{lbl}</div></div>')
def section(title,sub,pairs):
    return (f'<section style="display:flex;flex-direction:column;gap:12px"><div><div style="font:800 24px Manrope;color:#241F2B">{title}</div><div style="font:500 15px/22px Manrope;color:#4E4757;max-width:3200px">{sub}</div></div>'
            f'<div style="display:flex;gap:28px;flex-wrap:wrap;align-items:flex-start">{"".join(pairs)}</div></section>')
def build(fn,b,i,variants,curlab,proplab,w=412):
    out=[]
    for lbl,dark,k,text in variants:
        bb=b+('-Dark' if dark else ''); r=root(bb,i)
        out.append(pair(lbl,frame(fn(r,dark,False,k,text),dark,w),frame(fn(r,dark,True,k,text),dark,w),curlab,proplab,w))
    return out
V=lambda short,long_: [('Light · normal · short',False,1,short),('Light · normal · long',False,1,long_),('Dark · normal · long',True,1,long_),('Light · 130 % · long',False,1.3,long_),('Light · 200 % · long',False,2,long_),('Dark · 200 % · long',True,2,long_)]
def run():
    S1=section('7a · Android Minimal Add input','E-PhonesMinimal frame 6 (M3 modal bottom sheet). Single-line field: long text scrolls inside the field (native), it never wraps. iPhone Minimal Add is already Manrope 600 20 (reference below). Only the field text is scaled at 130 % and 200 %; the sheet itself is not reflowed here (its 200 % layout belongs to the platform).',
               build(s1,'E-PhonesMinimal',5,V('Gym 6pm 1h',LONG_A),'Manrope 600 19','Manrope 600 20'))
    S2=section('7b · Android Edit task title','E-Phones · Android Edit task (frame 6). The app bar "Edit task" stays native Roboto; only the task title changes. Multiline: the title wraps.',
               build(s2,'E-Phones',5,V('Gym',LONG_T),'Roboto 500 22','Manrope 700 24/30'))
    v3=V('Gym',LONG_T); v3.insert(0,('Light · empty (placeholder, Q5 colour)',False,1,None))
    S3=section('7b · Android Create task title','E-Phones · Android Add: Create task (frame 30). Cursor drawn as today; Gboard, selection and Material editing are the system\'s in both treatments.',
               build(s3,'E-Phones',29,v3,'Roboto 500 22','Manrope 700 24/30'))
    refs=[]
    for lab,b,i,w in [('iPhone Minimal Add · Manrope 600 20 (reference, unchanged)','E-PhonesMinimal',2,390),('iPhone Create task title · Manrope 700 24/30 (reference)','E-Phones',1,390),('Android Minimal Edit title · Manrope 800 21 (found, not part of 7b; unchanged)','E-PhonesMinimal',8,412)]:
        refs.append(f'<div style="display:flex;flex-direction:column;gap:6px"><div style="display:flex;gap:8px">{frame(root(b,i),False,w)}{frame(root(b+"-Dark",i),True,w)}</div><div style="font:600 13px/18px Manrope;color:#241F2B;max-width:{2*(int(w*Z)+16)+8}px">{lab}</div></div>')
    R=section('References (light | dark)','Already Manrope on iPhone and Minimal. Shown for comparison only.',refs)
    EV=open('h/g3c1_eval.html').read() if __import__('os').path.exists('h/g3c1_eval.html') else '<div id="eval"></div>'
    S=open(P+'E-G4-7-Q4-KeepBoth.dc.html').read()
    head=S[S.index('<link rel="preconnect"'):S.index('</helmet>')]
    page=('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<title>E · G3-C1 font comparison</title>\n<script src="./support.js"></script>\n</head>\n<body>\n<x-dc>\n<helmet>'+head+'</helmet>\n'
      '<div id="root" style="width: 3400px; height: HHHHpx; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px; overflow: hidden;">'
      '<header><h1 style="margin:0;font-size:38px;line-height:44px;font-weight:700;letter-spacing:-0.6px">G3-C1 · Task text font on Android · cleanup 7a and 7b · comparison for review (not applied)</h1>'
      '<p style="margin:8px 0 0;font-size:18px;color:#4E4757;max-width:3300px">ED-110 put task content in Manrope; ED-112 asked to see a comparison before changing text in phone sheets (G3-C1). Each pair uses the same real frame, text and width; only the field\'s font changes. Keyboard, selection, cursor, validation and accessibility are the platform\'s in both. Phones at 60 %.</p></header>'
      +EV+S1+S2+S3+R+'</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":3400,"height":HHHH}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body></html>\n')
    open(P+'E-G3-C1-Font-Comparison.dc.html','w').write(page); print('ok',len(page))
if __name__=='__main__': run()
