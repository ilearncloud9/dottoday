import re,sys; sys.path.insert(0,'h')
from bal import elem; from darkify import darkify
EP=open('w83/project/E-Phones.dc.html').read(); PM=open('w83/project/E-PhonesMinimal.dc.html').read()
E2=open('live82/project/E-Phones-2.dc.html').read(); P3=open('w83/project/E-Phones-3.dc.html').read()
FA=open('live82/project/E-FullA-v2.dc.html').read(); EM=open('live82/project/E-Minimal.dc.html').read()
WINS=lambda s:[m.start() for m in re.finditer(r'<div style="position: relative; width: 1280px; height: 800px;',s)]
def dev(s,lab,w=390):
    i=s.index(f'aria-label="{lab}"'); d0=s.index(f'<div style="position: relative; width: {w}px',i); return s[d0:elem(s,d0)]
def at(s,pos): return s[pos:elem(s,pos)]
def devof(s,needle,w=390):
    i=s.index(needle); d0=s.rfind(f'<div style="position: relative; width: {w}px',0,i); return s[d0:elem(s,d0)]
F={'iph_full':dev(EP,'iPhone Today'),'iph_min':dev(PM,'iPhone Now, minimal'),'and_full':dev(EP,'Android Today',412),'and_min':dev(PM,'Android Now, minimal',412),
 'create':dev(EP,'iPhone Add a task'),'brain':devof(E2,'role="dialog" aria-label="Add, Brain dump"'),'routine':devof(E2,'role="dialog" aria-label="Add, Routine"'),
 'editor':at(EP,395321),'and_editor':at(EP,480528),'colour':at(EP,496717),'allicons':at(EP,515877),'allcolours':devof(P3,'role="dialog" aria-label="All colours"'),
 'actions':at(EP,60653),'menu':dev(PM,'iPhone Today, minimal'),'disabled':at(EP,332713),
 'mac_full':at(FA,WINS(FA)[0]),'web_full':at(FA,WINS(FA)[1]),'mac_min':at(EM,WINS(EM)[0]),'web_min':at(EM,WINS(EM)[1])}
def mac_selected(D):
    # ED-176 / ED-178: selected row label #F3ECE4, icon #A3E2D9 (I1), teal highlight
    def fix(m):
        a=m.group(0); a=a.replace('<span style="flex: 1;">','<span style="flex: 1; color: #F3ECE4;">',1); return a
    return re.sub(r'<a href="#" aria-current="page"[^>]*>.*?</a>',fix,D,count=1,flags=re.S)
def frame_pair(key,label,w,h,z,notes):
    L=F[key]; D=darkify(L)
    if key in ('mac_full','mac_min'): D=mac_selected(D)
    # Q1-B (ED-179): contextual dotted thread on lighter surfaces, only where measured
    for idx in sorted({'mac_full':[0,1,2],'mac_min':[5],'web_full':[0],'web_min':[2]}.get(key,[]),reverse=True):
        ms=list(re.finditer(r'border-left: ?\d+px dotted #6B6369',D))
        if idx < len(ms): m=ms[idx]; D=D[:m.start()]+m.group(0).replace('#6B6369','#7B7279')+D[m.end():]
    box=lambda x,bg,fg: f'<div style="width:{int(w*z)+16}px;height:{int(h*z)+16}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{bg};color:{fg};overflow:hidden"><div style="zoom:{z}">{x}</div></div>'
    cap=f'<div style="font:500 14px Manrope;color:#4E4757;line-height:1.45;width:{2*int(w*z)+44}px"><div style="font:800 17px Manrope;color:#241F2B">{label}</div>'+''.join(f'<div>{n}</div>' for n in notes)+'</div>'
    lab=lambda t: f'<div style="font:700 13px Manrope;color:#6A6273;width:{int(w*z)+16}px">{t}</div>'
    return f'<section aria-label="{label}" style="display:flex;flex-direction:column;gap:8px"><div style="display:flex;gap:12px">{lab("Light · approved (with ED-179 text fixes)")}{lab("Dark · P1")}</div><div style="display:flex;gap:12px;align-items:flex-start">{box(L,"#E9E2D6","#241F2B")}{box(D,"#0E0C0E","#F3ECE4")}</div>{cap}</section>'
def detail():
    L=F['iph_full']; D=darkify(L)
    win=lambda x,bg,fg: f'<div style="width:585px;height:810px;overflow:hidden;border-radius:16px;background:{bg};color:{fg};position:relative"><div style="zoom:1.5;position:absolute;left:0;top:-160px">{x}</div></div>'
    return f'<section aria-label="Timeline close-up" style="display:flex;flex-direction:column;gap:8px"><div style="display:flex;gap:16px">{win(L,"#FBF7F1","#241F2B")}{win(D,"#171416","#F3ECE4")}</div><div style="font:500 14px Manrope;color:#4E4757;width:1190px"><div style="font:800 17px Manrope;color:#241F2B">Timeline close-up at 150 % · iPhone Today</div>Wake Up cap (amber 22 %, icon 4.87:1) · done dots filled with ink checks (≥ 5.07:1) · now card raised, arc indigo #7A7EDE · overlap knot in both task colours · now-bead #5BC4B8 with a ground border, time pill 7.36:1 · ahead thread dotted #6B6369 (T2-B) and ahead rings in dark task colours · 45-min free text secondary.</div></section>'
PZ=0.95; WZ=0.62
phones=[
 ('iph_full','iPhone · Full · Today',390,844,['Approved bottom row: glass tab bar with + in the bar\'s line (ED-124/132), Day chip. Done, now and ahead in one view; overlap knot.']),
 ('iph_min','iPhone · Minimal · Now',390,844,['Now-dot: raised centre, indigo arc, 25 % track, no shadow (T1). Minimal tab bar.']),
 ('and_full','Android · Full · Today',412,892,['Custom floating toolbar in dark tonal; tonal + (ED-125).']),
 ('and_min','Android · Minimal · Now',412,892,['Same toolbar; now-dot as iPhone.']),
 ('create','Create task',390,844,['Tabs Task · Brain dump · Routine; dark keyboard; scrim behind the sheet.']),
 ('brain','Brain dump',390,844,['Lines on raised; Today / Tomorrow chips; Plan it.']),
 ('routine','Routine',390,844,['Routine rows with dark task dots.']),
 ('editor','Task editor · steps and notes (iPhone)',390,844,['Steps with checks, notes field, alerts; sheet over a dimmed Today.']),
 ('and_editor','Task editor (Android)',412,892,['Material sheet; steps and notes.']),
 ('colour','Colour and icon · compact',390,844,['12 dark colours with ⋯ All colours; selected swatch keeps its check.']),
 ('allicons','All icons sheet',390,844,['Pinned 12-colour row, ⋯, icon grid and categories.']),
 ('allcolours','All colours half sheet',390,844,['Dottoday colours and Your colours; selected custom colour with check.']),
 ('actions','Task actions sheet (dimmed background)',390,844,['Done, Move, Shift the rest, Focus; Need more time? +5/+15/+30; scrim over Today.']),
 ('menu','Menu over Today (Minimal)',390,844,['Pull-down Day menu over the Earlier fold and thread.']),
 ('disabled','Disabled state (Wake Up settings)',390,844,['Disabled option at disabled text #8C838A (≥ 3.45:1); selected radio in teal.']),
]
wides=[('mac_full','Mac · Full Workspace',1280,800,['Sidebar: warm vibrancy drawn (native evidence on the token board); selected row label #F3ECE4 with icon #A3E2D9 (I1); inspector raised; context menu.']),
 ('mac_min','Mac · Minimal',1280,800,['Now pane, Day column, Gym context menu; selected row as Full.']),
 ('web_full','Web · Full Workspace',1280,800,['Solid dark surfaces, no glass; focus ring with 2 px gap.']),
 ('web_min','Web · Minimal',1280,800,['Solid sidebar; teal Add with ink.'])]
def row(t,items): return f'<div style="display:flex;flex-direction:column;gap:16px"><div style="font-size:24px;font-weight:800">{t}</div><div style="display:flex;gap:40px;row-gap:36px;align-items:flex-start;flex-wrap:wrap">{"".join(items)}</div></div>'
open_q='''<div style="width:1500px;border-radius:18px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.10);padding:22px 26px;font:500 15px Manrope;line-height:1.6;color:#4E4757;display:flex;flex-direction:column;gap:10px">
<div style="font:800 20px Manrope;color:#241F2B">Stage 2 review · method, checks and open questions</div>
<div><b>Method:</b> each dark frame is the approved light frame, converted token by token with the final Stage 1 map (P1, ED-175 task colours, caps, now-dot without shadow, thread #6B6369, now-bead; the Mac selected row uses the #F3ECE4 label and #A3E2D9 icon). No geometry, copy, navigation or workflow changed; light frames are untouched.</div>
<div><b>Checks run on the rendered frames:</b> automated text contrast for every text element against its resolved background: all pass except the system-drawn iOS keyboard letters (4.46), visual inspection of rings, checks, sheets, scrims, menus and focus rings; frame clipping.</div>
<div><b>Q1 resolved B (ED-179):</b> dotted ahead thread #6B6369 on the ground (3.15:1, 38 segments); #7B7279 only where a segment sits on a lighter surface (6 segments: Mac and web Workspace on raised 3.32, Mac Minimal tinted row 3.59, web Minimal hover 3.22). Behind a dimming scrim the thread stays dimmed (inert). On a popover #7B7279 would be 2.72:1: no thread is drawn there; if one is added, it needs its own correction.</div>
<div><b>Text corrections (ED-179, light and dark):</b> "Add a step" placeholder #8A8494 → #6F6978 in light (3.07–3.56 → ≥ 4.50:1) and #A0999F in dark (≥ 4.54:1); hex "#" prefix now in secondary text (#4E4757 light 8.75:1, #C7BEC4 dark 8.5:1) instead of the custom colour (violet 4.17, orange 3.58 in light). Applied on E-Phones, E-Phones-3, E-PhonesMinimal and in these frames. The iOS keyboard is Apple's own: its appearance and tests stay separate.</div>
<div><b>Drawn approximations (PENDING on devices):</b> iOS Liquid Glass, Android blur, Mac vibrancy (native Mac evidence on E-G4-6-Dark-Tokens), VoiceOver, TalkBack, Reduce Transparency, Increase Contrast.</div>
<div><b>Not merged:</b> no active board changes until you approve these screens.</div></div>'''
CHECK='''<script>window.addEventListener('load',()=>setTimeout(()=>{function rgb(s){const m=s.match(/rgba?\\(([^)]+)\\)/);if(!m)return null;const p=m[1].split(',').map(x=>parseFloat(x));return {r:p[0],g:p[1],b:p[2],a:p.length>3?p[3]:1}}
function lin(c){c/=255;return c<=0.03928?c/12.92:Math.pow((c+0.055)/1.055,2.4)}function L(c){return 0.2126*lin(c.r)+0.7152*lin(c.g)+0.0722*lin(c.b)}
function bg(el){let layers=[];for(let e=el;e;e=e.parentElement){const cs=getComputedStyle(e);if(cs.backgroundImage&&cs.backgroundImage!=='none'&&!cs.backgroundImage.startsWith('url'))return null;const c=rgb(cs.backgroundColor);if(c&&c.a>0){layers.push(c);if(c.a>=0.98)break}if(e.dataset&&e.dataset.theme)break}
let out={r:23,g:20,b:22};for(let i=layers.length-1;i>=0;i--){const c=layers[i];out={r:c.r*c.a+out.r*(1-c.a),g:c.g*c.a+out.g*(1-c.a),b:c.b*c.a+out.b*(1-c.a)}}return out}
const res=[];document.querySelectorAll('[data-theme="dark"]').forEach(box=>{const sec=box.closest('section').getAttribute('aria-label');box.querySelectorAll('*').forEach(el=>{if(![...el.childNodes].some(n=>n.nodeType===3&&n.textContent.trim()))return;const r=el.getBoundingClientRect();if(!r.width)return;let hid=false;for(let p=el;p&&p!==box;p=p.parentElement){if(p.getAttribute&&p.getAttribute('aria-hidden')==='true')hid=true;const cs=getComputedStyle(p);if(cs.opacity<0.6)hid=true}
const fg=rgb(getComputedStyle(el).color);const b=bg(el);if(!fg||!b)return;const c=(Math.max(L(fg),L(b))+0.05)/(Math.min(L(fg),L(b))+0.05);const fs=parseFloat(getComputedStyle(el).fontSize),fw=parseInt(getComputedStyle(el).fontWeight);const large=fs>=24||(fs>=18.66&&fw>=700);const need=large?3:4.5;if(c<need)res.push(sec+' | '+el.textContent.trim().slice(0,28)+' | '+c.toFixed(2)+(hid?' (decorative/hidden)':'')+' | fs '+fs)})});document.body.setAttribute('data-cc',res.join(' || '));},1500));</script>'''
html=open('h/head.html').read().replace('<title>E · Responsive</title>','<title>E · Dark key frames</title>').replace('</style>','''.blk{position:absolute;box-sizing:border-box;margin:0;padding:0;border:0;border-radius: 18px;background:#FFFDF9;box-shadow:none;text-align:left;font-family:Manrope,system-ui,sans-serif;color:#241F2B;overflow:hidden;cursor:grab}
.blk-d{position:absolute;box-sizing:border-box;margin:0;padding:0;border:0;border-radius: 18px;background:#28232A;box-shadow:none;text-align:left;font-family:Manrope,system-ui,sans-serif;color:#F3ECE4;overflow:hidden;cursor:grab}
.dot{position:absolute;box-sizing:border-box;border-radius:50%;display:flex;align-items:center;justify-content:center}
</style>''')
def build(check=False):
    pairs=[frame_pair(k,l,w,h,PZ,n) for k,l,w,h,n in phones]
    wp=[frame_pair(k,l,w,h,WZ,n) for k,l,w,h,n in wides]
    body='<div style="width: 3600px; height: 6900px; box-sizing: border-box; padding: 40px; background: #F3ECE2; font-family: Manrope, system-ui, sans-serif; color: #241F2B; display: flex; flex-direction: column; gap: 44px; overflow: hidden;">'
    body+='<header><h1 style="margin:0;font-size:38px;line-height:44px;font-weight:700;letter-spacing:-0.6px">G4-6 · Dark mode · Stage 2 visual review · light and dark side by side · final for approval (not merged)</h1><p style="margin:8px 0 0;font-size:18px;color:#4E4757">Final Stage 1 tokens (ED-174 to ED-178), Q1-B and the two text corrections (ED-179). Phones at 95 %, Mac and web at 62 %, a timeline close-up at 150 %. Exports: v1.46-working/captures (2× PNG per pair) and a 21-page PDF.</p></header>'
    body+=row('1 · Phones · Full and Minimal',pairs[0:4])+row('2 · Add, editor and colour',pairs[4:8])+row('3 · Editor, colour and icon pickers',pairs[8:12])+row('4 · Sheets, menus, disabled',pairs[12:15]+[detail()])+row('5 · Mac and web',wp)+'<div>'+open_q+'</div></div>'
    return html+body.replace('background:#0E0C0E;color:#F3ECE4','background:#0E0C0E;color:#F3ECE4" data-theme="dark" data-x="').replace('data-theme="dark" data-x=";','data-theme="dark" style="')+('\n</x-dc>'+(CHECK if check else '')+'\n<script type="text/x-dc" data-dc-script data-props=\'{"$preview":{"width":3600,"height":6900}}\'>\nclass Component extends DCLogic {\n  renderVals() { return {}; }\n}\n</script>\n</body>\n</html>\n')
