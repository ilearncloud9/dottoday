import sys; sys.path.insert(0,'h')
from dark import *
p=P['P1']; q=P['P2']
SURF=['ground','surface','raised','sheet','popover']
def sw(c,w=64,h=40,txt='',fg='#000',extra=''):
    return f'<span style="display:inline-flex;align-items:center;justify-content:center;width:{w}px;height:{h}px;border-radius:8px;background:{c};color:{fg};font:700 11px ui-monospace,Menlo,monospace;box-shadow:inset 0 0 0 1px rgba(255,255,255,.08){extra}">{txt}</span>'
def foundations(k,pp,rec):
    rows=''
    for s in SURF:
        c=pp[s]
        rows+=f'''<tr><td style="padding:6px 8px">{s}</td><td>{sw(c,90,36,c,pp["text"])}</td>
<td style="background:{c};color:{pp["text"]};padding:6px 10px;font:600 14px Manrope">Text {cr(pp["text"],c):.1f}</td>
<td style="background:{c};color:{pp["text2"]};padding:6px 10px;font:500 13px Manrope">Secondary {cr(pp["text2"],c):.1f}</td>
<td style="background:{c};color:{pp["disabled"]};padding:6px 10px;font:500 13px Manrope">Disabled {cr(pp["disabled"],c):.1f}</td>
<td style="background:{c};color:{pp["accent"]};padding:6px 10px;font:700 13px Manrope">Teal {cr(pp["accent"],c):.1f}</td>
<td style="background:{c};padding:6px 10px"><span style="display:inline-block;width:70px;height:26px;border-radius:8px;box-shadow:inset 0 0 0 1.5px {pp["outline"]}"></span> <span style="color:{pp["text2"]};font:500 12px Manrope">{cr(pp["outline"],c):.1f}</span></td></tr>'''
    other=''.join(f'<div style="display:flex;align-items:center;gap:8px;margin:4px 12px 4px 0;font:500 12px Manrope;color:#4E4757">{sw(pp[t],34,24)}<span><b>{t}</b> {pp[t]}</span></div>' for t in ['text','text2','disabled','divider','outline','accent','accentInk','tonal','tonalText','focus','error','warning','success'])
    return f'''<div style="border-radius:16px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.1);padding:16px 18px;display:flex;flex-direction:column;gap:10px">
<div style="font:800 18px Manrope">{k} · {pp["name"]} {'<span class="tb">Recommended</span>' if rec else '<span class="tn">Alternative</span>'}</div>
<table style="border-collapse:collapse;font:500 13px Manrope;color:#241F2B">{rows}</table>
<div style="display:flex;flex-wrap:wrap">{other}</div>
<div style="font:500 12px Manrope;color:#4E4757">Divider ({pp["divider"]}) is decorative ({cr(pp["divider"],pp["surface"]):.1f}:1); control borders use <b>outline</b> ({min(cr(pp["outline"],pp[s]) for s in SURF):.1f}:1 or better on every surface). Disabled text is exempt from 4.5:1 but stays above 3:1.</div></div>'''
def taskrow(n,key,f):
    surf=[p[s] for s in SURF]; d=darkfill(f,surf); ink=p['ground']; inkc=cr(d,ink)
    cells=''.join(f'<td style="background:{p[s]};padding:8px 10px;text-align:center"><span style="display:inline-block;width:26px;height:26px;border-radius:50%;box-shadow:inset 0 0 0 4px {d};vertical-align:middle"></span><div style="font:600 11px ui-monospace,Menlo;color:{p["text2"]};margin-top:2px">{cr(d,p[s]):.2f}</div></td>' for s in SURF)
    track=blend(d,p['surface'],0.25)
    prog=f'<span style="display:inline-block;width:30px;height:30px;border-radius:50%;background:radial-gradient(closest-side,{p["surface"]} calc(100% - 4.5px),transparent calc(100% - 4px)),conic-gradient({d} 0 65%,{track} 65% 100%)"></span>'
    done=f'<span style="display:inline-flex;align-items:center;justify-content:center;width:28px;height:28px;border-radius:50%;background:{d};color:{ink}"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg></span>'
    changed='' if d.upper()==f.upper() else f'<div style="font:600 11px Manrope;color:#6E4300">lightened for dark</div>'
    return f'''<tr><td style="padding:6px 10px;background:#FFFDF9"><b>{n}</b><div style="font:500 11px ui-monospace,Menlo;color:#6A6273">{key}</div></td>
<td style="padding:6px;background:#FBF7F1;text-align:center">{sw(f,56,28,f,'#fff' if cr(f,'#FFFFFF')>=3 else '#241F2B')}</td>
<td style="padding:6px;background:#FFFDF9;text-align:center">{sw(d,56,28,d,ink)}{changed}</td>
{cells}
<td style="background:{p["surface"]};padding:8px 10px;text-align:center">{prog}</td>
<td style="background:{p["surface"]};padding:8px 10px;text-align:center">{done}<div style="font:600 11px ui-monospace,Menlo;color:{p["text2"]}">ink {inkc:.2f}</div></td></tr>'''
th=''.join(f'<th style="padding:6px 8px;font:700 12px Manrope;text-align:center">{h}</th>' for h in ['Colour','Light fill (approved)','Dark fill = ring','On ground','On surface','On raised','On sheet','On popover','Now: arc + 25 % track','Done: check'])
palette=f'''<div style="border-radius:16px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.1);padding:16px 18px;display:flex;flex-direction:column;gap:10px">
<div style="font:800 18px Manrope">Task colours on P1 · all 12 families · measured</div>
<table style="border-collapse:collapse;font:500 13px Manrope;color:#241F2B"><tr>{th}</tr>{''.join(taskrow(*t[:2],t[2]) for t in TASK)}</table>
<div style="font:500 13px Manrope;color:#4E4757;line-height:1.5">Rule: a colour keeps its approved light fill on dark when that fill already reaches 3:1 against every dark surface (7 of 12). Otherwise it is lightened in the same hue (saturation capped at 70 %, no neon) until it does. In dark, the ring, the now arc and the done fill all use this dark fill (the light-mode ring tokens of ED-155 are darker and are not reused). Glyphs and checks inside filled dots use the ground ink (≥ 4.37:1 on all 12). The now track is the colour at 25 % over the surface: decorative, since "18 min left" carries the progress. Stored keys are unchanged; brown, plum and olive remain unapproved keys (data review), shown here only for the visual decision.</div></div>'''
def btn(bg,fg,txt,extra=''): return f'<span style="display:inline-flex;align-items:center;justify-content:center;height:40px;padding:0 16px;border-radius:12px;background:{bg};color:{fg};font:700 14px Manrope;{extra}">{txt}</span>'
comp=f'''<div style="border-radius:16px;background:{p["surface"]};padding:18px;display:flex;flex-direction:column;gap:14px;color:{p["text"]};font:500 13px Manrope">
<div style="font:800 18px Manrope">Controls and states on P1</div>
<div style="display:flex;gap:12px;align-items:center;flex-wrap:wrap">{btn(p["accent"],p["accentInk"],"Done")}<span style="font-size:12px;color:{p["text2"]}">ink on teal {cr(p["accentInk"],p["accent"]):.1f}</span>{btn(p["tonal"],p["tonalText"],"Focus")}<span style="font-size:12px;color:{p["text2"]}">{cr(p["tonalText"],p["tonal"]):.1f}</span>{btn("transparent",p["text"],"Need more time?","box-shadow:inset 0 0 0 1.5px "+p["outline"])}{btn(p["accent"],p["accentInk"],"Focused","outline:3px solid "+p["focus"]+";outline-offset:2px")}<span style="font-size:12px;color:{p["text2"]}">focus ring {cr(p["focus"],p["surface"]):.1f} on surface, 2 px gap (ring vs teal alone 1.2)</span></div>
<div style="display:flex;gap:18px;align-items:center;flex-wrap:wrap">
<span><span style="display:inline-block;width:51px;height:31px;border-radius:16px;background:#11615C;position:relative;vertical-align:middle"><span style="position:absolute;right:2px;top:2px;width:27px;height:27px;border-radius:50%;background:#fff"></span></span> approved teal #11615C: <b style="color:{p["error"]}">2.1 on raised ✗</b></span>
<span><span style="display:inline-block;width:51px;height:31px;border-radius:16px;background:#2A8C83;position:relative;vertical-align:middle"><span style="position:absolute;right:2px;top:2px;width:27px;height:27px;border-radius:50%;background:#fff"></span></span> proposed dark on-tint <b>#2A8C83</b>: 3.8 on raised, 3.5 on sheet, white thumb 4.1</span></div>
<div style="display:flex;gap:18px;align-items:center;flex-wrap:wrap">
<span><span style="display:inline-flex;width:20px;height:20px;border-radius:4px;background:{p["accent"]};color:{p["accentInk"]};align-items:center;justify-content:center;vertical-align:middle">✓</span> Android checkbox on ({cr(p["accentInk"],p["accent"]):.1f})</span>
<span><span style="display:inline-block;width:18px;height:18px;border-radius:4px;box-shadow:inset 0 0 0 2px {p["text2"]};vertical-align:middle"></span> off ({cr(p["text2"],p["raised"]):.1f})</span>
<span style="padding:4px 10px;border-radius:8px;background:{p["raised"]};color:{p["error"]}">⚠︎ Couldn't sync · Retry ({cr(p["error"],p["raised"]):.1f})</span>
<span style="padding:4px 10px;border-radius:8px;background:{p["raised"]};color:{p["warning"]}">⏰ Alarms off on iPad ({cr(p["warning"],p["raised"]):.1f})</span>
<span style="padding:4px 10px;border-radius:8px;background:{p["raised"]};color:{p["success"]}">✓ Synced ({cr(p["success"],p["raised"]):.1f})</span></div>
<div style="font-size:12px;color:{p["text2"]}">States always carry an icon and words, never colour alone. Error is for real failures (sync), never for unfinished tasks (no-shame rule).</div></div>'''
def mat(title,inner,notes,tag='th',tagtext='Proposed · needs your approval'):
    return f'<div style="width:300px;display:flex;flex-direction:column;gap:8px"><div style="font:800 15px Manrope">{title}</div>{inner}<div style="font:500 12px Manrope;color:#4E4757;line-height:1.45">{notes}</div><span class="{tag}" style="white-space:normal;align-self:flex-start">{tagtext}</span></div>'
def phonebar(bg,extra,tab=True):
    items=''.join(f'<span style="flex:1;display:flex;flex-direction:column;align-items:center;gap:2px;font:600 10px -apple-system;color:{p["accent"] if i==0 else p["text2"]}"><span style="width:20px;height:16px;border-radius:4px;background:{p["accent"] if i==0 else p["text2"]};opacity:.9"></span>{t}</span>' for i,t in enumerate(['Today','Inbox','Calendar','Search']))
    return f'<div style="position:relative;height:120px;border-radius:14px;background:linear-gradient(160deg,#3A3240,#1B1A22 60%,#2C3A3A);overflow:hidden"><div style="position:absolute;left:12px;right:70px;bottom:12px;height:52px;border-radius:26px;display:flex;align-items:center;padding:0 6px;{bg};{extra}">{items}</div><div style="position:absolute;right:12px;bottom:12px;width:52px;height:52px;border-radius:50%;background:{p["accent"]};color:{p["accentInk"]};display:flex;align-items:center;justify-content:center;font:700 26px Manrope">+</div></div>'
mats=[
 mat('iPhone · Liquid Glass (iOS 26)',phonebar('background:rgba(40,36,40,.45);backdrop-filter:blur(14px) saturate(160%)','box-shadow:inset 0 1px 0 rgba(255,255,255,.18),inset 0 0 0 1px rgba(255,255,255,.10)'),'Genuine system glass in dark; no app tint on the glass. Selected tab in teal '+p["accent"]+'; + is a teal button with ink icon (7.7:1); Day chip on glass. Drawing approximates the system material.'),
 mat('iPhone · iOS 16–18 fallback',phonebar('background:rgba(37,33,36,.80);backdrop-filter:blur(20px)',''),'System thin material (dark), approximated as rgba(37,33,36,.80) + blur. Same teal and +.'),
 mat('iPhone · Reduce Transparency / Increase Contrast',phonebar('background:'+p["sheet"],'box-shadow:inset 0 0 0 1px #5A5258'),'Reduce Transparency: solid sheet '+p["sheet"]+' with a 1 px #5A5258 edge. Increase Contrast: separators #5A5258, secondary text uses primary text, outline 1.5 px.'),
 mat('Android · floating toolbar (dark)',f'<div style="position:relative;height:120px;border-radius:14px;background:{p["surface"]}"><div style="position:absolute;left:12px;right:80px;bottom:16px;height:64px;border-radius:32px;background:rgba(43,38,42,.78);backdrop-filter:blur(24px);display:flex;align-items:center;justify-content:space-around;box-shadow:0 2px 6px rgba(0,0,0,.35)"><span style="padding:6px 16px;border-radius:16px;background:{p["tonal"]};color:{p["tonalText"]};font:600 11px Roboto">Now</span><span style="color:{p["text2"]};font:500 11px Roboto">Today</span><span style="color:{p["text2"]};font:500 11px Roboto">Inbox</span></div><div style="position:absolute;right:12px;bottom:20px;width:56px;height:56px;border-radius:16px;background:{p["tonal"]};color:{p["tonalText"]};display:flex;align-items:center;justify-content:center;font:700 24px Roboto">+</div></div>','Tonal toolbar rgba(43,38,42,.78) + blur 24 (frosted, no rims); selected pill '+p["tonal"]+' with '+p["tonalText"]+' (8.4:1). Solid fallback: '+p["raised"]+'. FAB: tonal.'),
]
macs=''
for name,tint,a in [('D1 · warm tint #3B2F2A at 30 % (recommended)','#3B2F2A',0.30),('D2 · warm tint #3B2F2A at 45 %','#3B2F2A',0.45),('D3 · no tint (system dark only)',None,0)]:
    cells=''
    for bd in ['#1E2A3A','#D8D4CC','#6A3A2A']:
        base=blend('#242426',bd,0.82); res=blend(tint,base,a) if tint else base
        cells+=f'<div style="flex:1;border-radius:8px;overflow:hidden;background:{bd};padding:6px"><div style="border-radius:6px;background:{res};padding:6px 8px;font:600 12px -apple-system;color:{p["text"]}">Now<div style="color:{p["text2"]};font-weight:500">Inbox 3</div><div style="font:500 10px ui-monospace,Menlo;color:{p["text2"]}">{res} · {cr(p["text"],res):.1f}</div></div></div>'
    macs+=f'<div style="display:flex;flex-direction:column;gap:4px"><div style="font:700 13px Manrope">{name}</div><div style="display:flex;gap:6px">{cells}</div></div>'
mats.append(mat('Mac · sidebar vibrancy (dark)',f'<div style="display:flex;flex-direction:column;gap:10px">{macs}</div>','Genuine NSVisualEffectView sidebar material (dark) with a warm layer inside it, simulated over a blue, light and red wallpaper. The light-mode #EFE7DB at 35 % is not reused. Reduce Transparency: solid #231F22 (text 13.9:1). Real measurement needs a Mac spike: PENDING.'))
mats.append(mat('Web · solid dark',f'<div style="position:relative;height:120px;border-radius:14px;background:{p["ground"]}"><div style="position:absolute;left:0;right:0;bottom:0;height:52px;background:{p["surface"]};box-shadow:0 -1px 0 {p["divider"]};display:flex;align-items:center;justify-content:space-around;font:600 11px Manrope;color:{p["text2"]}"><span style="padding:4px 12px;border-radius:8px;background:{p["tonal"]};color:{p["tonalText"]}">Today</span><span>Inbox</span><span>Calendar</span><span>Search</span></div><span style="position:absolute;right:12px;bottom:62px;height:40px;padding:0 14px;border-radius:12px;background:{p["accent"]};color:{p["accentInk"]};display:flex;align-items:center;font:700 14px Manrope">+ Add</span></div>','Solid surfaces only, no glass imitation. Bottom bar '+p["surface"]+' with a hairline; selected '+p["tonal"]+'; focus ring '+p["focus"]+' with 2 px offset. <code>color-scheme: dark</code> and the theme colour set before first paint (no light flash).'))
sample=f'''<div style="width:340px;border-radius:24px;background:{p["ground"]};padding:16px;font-family:Manrope;color:{p["text"]}">
<div style="font:700 22px -apple-system">Tue 3 Nov</div><div style="font:600 13px Manrope;color:{p["text2"]};margin-bottom:10px">Rest of today · until Wind Down at 11:00 PM</div>'''
rows=[('Morning run','6:45–7:30 AM','#E2725B','done'),('Deep work: roadmap','9:00–11:00 AM · Now, 18 min left','#6D71DB','now'),('Call with Sam','10:30–11:00 AM','#2A9D8F','ahead'),('Lunch','12:30–1:15 PM','#D9668F','ahead'),('Weekly reset','3:00–4:00 PM','#B061A1','ahead')]
for t,tm,c,st in rows:
    if st=='done': dot=f'<span style="width:30px;height:30px;border-radius:50%;background:{c};color:{p["ground"]};display:flex;align-items:center;justify-content:center;font-weight:800">✓</span>'
    elif st=='now': dot=f'<span style="width:34px;height:34px;border-radius:50%;background:radial-gradient(closest-side,{p["raised"]} calc(100% - 5px),transparent calc(100% - 4.5px)),conic-gradient({c} 0 85%,{blend(c,p["raised"],0.25)} 85% 100%)"></span>'
    else: dot=f'<span style="width:30px;height:30px;border-radius:50%;box-shadow:inset 0 0 0 4px {c}"></span>'
    bg=p['raised'] if st=='now' else 'transparent'
    sample+=f'<div style="display:flex;align-items:center;gap:12px;padding:8px;border-radius:16px;background:{bg}"><span style="width:36px;display:flex;justify-content:center">{dot}</span><span><span style="display:block;font-size:12px;color:{p["accent"] if st=="now" else p["text2"]}">{tm}</span><span style="display:block;font:700 16px Manrope;color:{p["text2"] if st=="done" else p["text"]}">{t}</span></span></div>'
sample+='<div style="margin-top:8px;font:500 11px Manrope;color:'+p["text2"]+'">Token sample only (not a key frame). Key frames come in Stage 2.</div></div>'
notes=f'''<div style="width:760px;border-radius:16px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.1);padding:18px 22px;font:500 14px Manrope;line-height:1.55;color:#4E4757;display:flex;flex-direction:column;gap:8px">
<div style="font:800 18px Manrope;color:#241F2B">Findings, corrections and theme behaviour</div>
<div><b>Passes (P1):</b> text ≥ 10.8:1 and secondary ≥ 7.0:1 on every surface; teal ≥ 6.0:1; control outline ≥ 3.45:1; all 12 task rings ≥ 3.02:1 on every surface; glyphs and checks inside filled dots ≥ 4.37:1; error, warning and success text ≥ 5.4:1.</div>
<div><b>Needs correction:</b> (1) iOS switch: the approved teal #11615C is 2.1:1 on dark rows → dark on-tint <b>#2A8C83</b> (3.8:1, white thumb 4.1:1); light mode keeps #11615C (ED-112). (2) The focus ring is only 1.2:1 against a teal button → always drawn with a 2 px gap of surface. (3) Five task colours (indigo, violet, slate, brown, plum) are lightened for dark; their identity is kept (same hue).</div>
<div><b>Decorative / exempt:</b> dividers (≈ 1.3–1.6:1), the now track, and disabled text (≥ 3.45:1). Selected tabs also change icon and text colour, not only background (tonal vs surface 1.4:1).</div>
<div><b>Theme behaviour:</b> Appearance Light · Dark · Auto (ED-161); Auto follows the platform setting. Switching theme never loses unsaved edits, changes the task or date, commits a proposal, resets navigation or recreates an open editor. Full and Minimal unchanged. Tablets record the same tokens; layouts in Round 2.</div>
<div style="font-size:12.5px">All values are proposals; ChatGPT sample colours were not used. Contrast is WCAG 2.x relative luminance, computed. Device rendering of glass and vibrancy: <b>PENDING</b>.</div></div>'''
def row(t,items,extra=''): return f'<div style="display:flex;flex-direction:column;gap:12px"><div style="font-size:20px;font-weight:800">{t}</div><div style="display:flex;gap:24px;align-items:flex-start;flex-wrap:wrap">{"".join(items)}{extra}</div></div>'
html=open('h/head.html').read().replace('<title>E · Responsive</title>','<title>E · Dark tokens</title>')+'<div style="width: 2900px; height: 3600px; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 34px; overflow: hidden;">'
html+='<header><h1 style="margin:0;font-size:34px;line-height:40px;font-weight:700;letter-spacing:-0.6px">G4-6 · Dark mode · Stage 1: token system (decision board, not approved)</h1><p style="margin:6px 0 0;font-size:17px;color:#4E4757">Warm, refined dark for Concept E: two foundation options, all 12 task colours measured on every dark surface, controls, and native material recipes per platform. No active board changes until you approve.</p></header>'
html+=row('1 · Foundations',[foundations('P1',p,True),foundations('P2',q,False)])
html+=row('2 · Task colours',[palette,sample])
html+=row('3 · Controls, states and native materials',[comp]+mats)
html+=row('4 · Accessibility and behaviour',[notes])
html+='</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":2900,"height":3600}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n'
mkd='w70/project'; import os; os.makedirs(mkd,exist_ok=True)
open(mkd+'/E-G4-6-Dark-Tokens.dc.html','w').write(html)
