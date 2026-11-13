import re,sys; sys.path.insert(0,'h')
from bal import elem; from darkify import darkify
EP=open('live58/project/E-Phones.dc.html').read(); PM=open('live58/project/E-PhonesMinimal.dc.html').read()
E2=open('live56/project/E-Phones-2.dc.html').read(); FA=open('live58/project/E-FullA-v2.dc.html').read(); EM=open('live58/project/E-Minimal.dc.html').read()
def dev(s,lab,w=390):
    i=s.index(f'aria-label="{lab}"'); d0=s.index(f'<div style="position: relative; width: {w}px',i); return s[d0:elem(s,d0)]
def at(s,pos): return s[pos:elem(s,pos)]
def devcontaining(s,needle,w=390):
    i=s.index(needle); d0=s.rfind(f'<div style="position: relative; width: {w}px',0,i); return s[d0:elem(s,d0)]
F={}
F['iph_full']=dev(EP,'iPhone Today'); F['iph_min']=dev(PM,'iPhone Now, minimal')
F['and_full']=dev(EP,'Android Today',412); F['and_min']=dev(PM,'Android Now, minimal',412)
F['create']=dev(EP,'iPhone Add a task'); F['brain']=at(E2,2821); F['routine']=at(E2,9774)
F['editor']=devcontaining(EP,'<div role="dialog" aria-label="Colour and icon"'); F['menu']=dev(PM,'iPhone Today, minimal')
F['mac_full']=at(FA,3662); F['web_full']=at(FA,56730); F['mac_min']=at(EM,5560); F['web_min']=at(EM,62047)
# D1 approved selected label: dark Mac sidebar selected row text uses primary text (handled by darkify mapping teal->teal; fix below)
def pair(key,label,w,h,z,notes,tag='th',tagtext='Stage 2 key frame · needs your visual approval'):
    L=F[key]; D=darkify(L)
    if key in ('mac_min','mac_full'):
        D=D.replace('rgba(43,38,42,0.78); backdrop-filter: blur(30px)','rgba(43,38,42,0.78); backdrop-filter: blur(30px) saturate(140%)')
    box=lambda x,bg,fg: f'<div style="width:{int(w*z)+16}px;height:{int(h*z)+16}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{bg};color:{fg}"><div style="zoom:{z}">{x}</div></div>'
    cap=f'<div style="font:500 13px Manrope;color:#4E4757;line-height:1.45;max-width:{2*int(w*z)+40}px"><div style="font:800 15px Manrope;color:#241F2B">{label}</div>'+''.join(f'<div>{n}</div>' for n in notes)+f'<span class="{tag}" style="white-space:normal">{tagtext}</span></div>'
    return f'<section aria-label="{label}" style="display:flex;flex-direction:column;gap:10px"><div style="display:flex;gap:12px;align-items:flex-start">{box(L,"#E9E2D6","#241F2B")}{box(D,"#0E0C0E","#F3ECE4")}</div><div style="display:flex;gap:{int(w*z)-60}px;font:700 12px Manrope;color:#6A6273"><span>Light (approved, unchanged)</span><span>Dark (P1)</span></div>{cap}</section>'
def row(t,items,extra=''): return f'<div style="display:flex;flex-direction:column;gap:14px"><div style="font-size:22px;font-weight:800">{t}</div><div style="display:flex;gap:44px;align-items:flex-start;flex-wrap:wrap">{"".join(items)}{extra}</div></div>'
PZ=0.8; WZ=0.5
r1=[pair('iph_full','iPhone · Full · Today',390,844,PZ,['Genuine dark Liquid Glass tab bar and Day chip (drawn approximation); + in teal with ink icon. Done dots filled with ink checks; now card raised; thread dotted at T2-B.']),
    pair('iph_min','iPhone · Minimal · Now',390,844,PZ,['Large now-dot: raised centre, indigo arc, 25 % track, no shadow (T1 recommended).']),
    pair('and_full','Android · Full · Today',412,892,PZ,['Dark tonal floating toolbar (rgba 43,38,42 at 78 % + blur), tonal selected pill, tonal +.']),
    pair('and_min','Android · Minimal · Now',412,892,PZ,['Same tokens as iPhone; Material toolbar and FAB in dark tonal.'])]
r2=[pair('create','Create task (iPhone)',390,844,PZ,['Tabs Task · Brain dump · Routine; field and chips on raised; teal Create with ink.']),
    pair('brain','Brain dump',390,844,PZ,['Lines on raised; nothing added until Plan it.']),
    pair('routine','Routine',390,844,PZ,['Routine rows in task colours (dark values).']),
    pair('editor','Task editor · colour and icon',390,844,PZ,['12-colour row in dark values with ⋯ All colours; selected swatch keeps its check in ink.'])]
r3=[pair('menu','Menu over Today (Minimal, iPhone)',390,844,PZ,['Glass pull-down menu in dark; Earlier fold; sheets stay solid.']),
    pair('mac_full','Mac · Full Workspace',1280,800,WZ,['Sidebar: D1 approximated in the drawing (native evidence on E-G4-6-Dark-Tokens); inspector raised; context menu popover.']),]
r4=[pair('mac_min','Mac · Minimal',1280,800,WZ,['Now pane on ground, Day column, Gym context menu. Selected sidebar row: primary text label (ED-176), teal pill and icon (I1 pending).']),
    pair('web_full','Web · Full Workspace',1280,800,WZ,['Solid dark surfaces, no glass; focus ring with 2 px gap.']),
    pair('web_min','Web · Minimal',1280,800,WZ,['Solid sidebar #28232A; teal Add with ink.'])]
open_items='''<div style="width:900px;border-radius:18px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.10);padding:20px 24px;font:500 14px Manrope;line-height:1.55;color:#4E4757;display:flex;flex-direction:column;gap:8px">
<div style="font:800 18px Manrope;color:#241F2B">Stage 2 · how these were made, and what is open</div>
<div><b>Method:</b> every dark frame is the approved light frame converted token by token with the approved P1 map (foundation, text, teal and tonal, the 12 dark task colours of ED-175, caps, orb track, thread T2-B, now-bead). No layout, copy or interaction changed; the light frames on the active boards are untouched.</div>
<div><b>Provisional until you choose:</b> I1 (selected Mac icon #A3E2D9), T1 (now-dot without shadow), T2-B (dotted thread #6B6369). These frames use the recommended options.</div>
<div><b>Drawn approximations, not evidence:</b> iOS Liquid Glass, Android blur and Mac vibrancy are approximated in HTML. Native Mac D1 evidence is on E-G4-6-Dark-Tokens; iPhone glass and Android blur on devices: PENDING. VoiceOver, TalkBack, Reduce Transparency, Increase Contrast: PENDING.</div>
<div><b>Not merged:</b> nothing is applied to E-Phones, E-PhonesMinimal, E-Minimal, E-FullA-v2 or E-MobileWeb until you approve these frames. Tablets: dark tokens apply; layouts in Round 2.</div></div>'''
html=open('h/head.html').read().replace('<title>E · Responsive</title>','<title>E · Dark key frames</title>').replace('</style>','''.blk{position:absolute;box-sizing:border-box;margin:0;padding:0;border:0;border-radius: 18px;background:#FFFDF9;box-shadow:none;text-align:left;font-family:Manrope,system-ui,sans-serif;color:#241F2B;overflow:hidden;cursor:grab}
.blk-d{position:absolute;box-sizing:border-box;margin:0;padding:0;border:0;border-radius: 18px;background:#28232A;box-shadow:none;text-align:left;font-family:Manrope,system-ui,sans-serif;color:#F3ECE4;overflow:hidden;cursor:grab}
.dot{position:absolute;box-sizing:border-box;border-radius:50%;display:flex;align-items:center;justify-content:center}\n</style>''')+'<div style="width: 3400px; height: 4000px; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 40px; overflow: hidden;">'
html+='<header><h1 style="margin:0;font-size:36px;line-height:42px;font-weight:700;letter-spacing:-0.6px">G4-6 · Dark mode · Stage 2: key frames, light and dark (decision board, not approved)</h1><p style="margin:6px 0 0;font-size:17px;color:#4E4757">Representative Full and Minimal frames for iPhone, Android, Mac and web, plus Create task, Brain dump, Routine, the editor with the colour picker, and a menu, each beside its approved light frame.</p></header>'
html+=row('1 · Phones, Full and Minimal',r1)
html+=row('2 · Add, editor and colour',r2)
html+=row('3 · Menu and Mac Full',r3,extra=open_items)
html+=row('4 · Mac Minimal and web',r4)
html+='</div>\n</x-dc>\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":3400,"height":4000}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n'
open('w70/project/E-G4-6-Dark-Frames.dc.html','w').write(html)
