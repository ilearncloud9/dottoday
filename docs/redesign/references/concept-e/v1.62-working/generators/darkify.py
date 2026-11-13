import re,sys
sys.path.insert(0,'h')
from bal import elem
# light -> dark token map (P1, ED-174/175; T1 no shadow, T2-B dotted, I1 icon provisional)
HEX={
 '#FBF7F1':'#171416','#FFFDF9':'#28232A','#F6F1EA':'#1F1B1E','#F1ECE4':'#2F2A30','#ECE5DC':'#37313A','#F3EEE6':'#1F1B1E','#F3ECE2':'#171416','#FAF6EF':'#1F1B1E','#F7F2EB':'#1F1B1E','#EDE7DF':'#2F2A30','#EFE7DB':'#28232A','#E7DFEF':'#37313A','#DDD7E0':'#4A4348',
 '#241F2B':'#F3ECE4','#2E2836':'#F3ECE4','#4E4757':'#C7BEC4','#6A6273':'#C7BEC4','#7A7280':'#8C838A','#8A8494':'#8C838A','#BEB6C7':'#6B6369',
 '#11615C':'#5BC4B8','#0B4642':'#A3E2D9','#E2EFEC':'#1E3A37','#CFE8E4':'#1E3A37','#062F2C':'#A3E2D9',
 '#5B5FD6':'#7A7EDE','#8B5CF6':'#9672E6','#6E6A75':'#898590','#8C6A4F':'#A67F60','#9E4F8F':'#B76FA9','#7F8A3A':'#828E3C',
 '#DF6147':'#E2725B','#AF7E22':'#D9A23A','#338ED1':'#4A9BD6','#469763':'#4CA36B',
 '#E4E3F7':'#302F48','#E6E3F7':'#333148','#4B3FB0':'#A9ACEB','#FBEBC8':'#483924','#9A5A0E':'#D9A23A',
 '#C8322F':'#B5473C','#FFFFFF':'#171416','#fff':'#171416','#FFF':'#171416','#ffffff':'#171416',
 '#CFC6D6':'#4A4348','#D75E89':'#D9668F','#3B3543':'#E6DEE2','#6E6E73':'#C7BEC4','#289588':'#2A9D8F','#A39BAA':'#9A9198','#F7F5F8':'#2F2A30','#3C3C43':'#EBEBF5','#ECE8EE':'#3E373D','#D9ECE9':'#1E3A37','#9C95A3':'#9A9198','#F5F1EB':'#1F1B1E','#E7E3EA':'#3E373D',
 '#ECE6EE':'#201D21','#FBF8FC':'#3B373D','#DCD4DF':'#2E2A30',
 '#6F6978':'#A0999F', '#6A6473':'#A0999F',  # Q5 (ED-196)
 '#E3F1E7':'#1E3A37','#1D6436':'#A3E2D9','#F1F0FB':'#28232A','#E9E2F0':'#3E373D',
}
def _rgba(m):
    r,g,b,a=int(m.group(1)),int(m.group(2)),int(m.group(3)),float(m.group(4))
    if (r,g,b)==(36,31,43): return f'rgba(255,245,235,{min(a*1.3,0.5):.2f})'
    if (r,g,b)==(255,255,255): return f'rgba(255,255,255,{a*0.16:.3f})'
    if (r,g,b)==(251,247,241): return f'rgba(23,20,22,{a:.2f})'
    if (r,g,b) in ((255,253,249),(250,247,252),(248,245,250),(242,235,226),(239,231,219),(207,232,228)): return f'rgba(43,38,42,{max(a,0.72):.2f})'
    if (r,g,b)==(17,97,92): return f'rgba(91,196,184,{a:.2f})'
    if (r,g,b)==(60,60,67): return f'rgba(235,235,245,{a:.2f})'
    return m.group(0)
def kb_dark(k):
    k=k.replace('rgba(234,234,239,0.96)','rgba(44,44,46,0.96)').replace('rgba(255,255,255,0.9)','rgba(255,255,255,0.12)')
    k=re.sub(r'background: #FFFFFF','background: #6C6C70',k); k=re.sub(r'background: #(ACB1B9|ABB0BA|B3B8C1|AEB3BC)','background: #4A4A4F',k)
    k=re.sub(r'color: #000000|color: #000\b','color: #FFFFFF',k); k=k.replace('#3C3C43','#EBEBF5')
    return k
def darkify(h):
    h=h.replace('background: #C8322F; color: #fff;','background: #B5473C; color: @@WHITE@@;')
    h=re.sub(r'color: ?#000000\b|color: ?#000\b','color: #F3ECE4',h)
    kbs=[]
    while 'data-kb=' in h:
        i=h.index('data-kb='); a=h.rfind('<div',0,i); e=elem(h,a); kbs.append(kb_dark(h[a:e])); h=h[:a]+f'@@KB{len(kbs)-1}@@'+h[e:]
    h=re.sub(r'background: rgba\(36,\s*31,\s*43,\s*([0-9.]+)\)',lambda m:f'background: rgba(0,0,0,{min(float(m.group(1))*2.2,0.6):.2f})' if float(m.group(1))>=0.15 else f'background: rgba(255,245,235,{float(m.group(1))*1.3:.2f})',h)
    keep=re.findall(r'0 0 0 (?:8|9)px #241F2B',h)
    h=re.sub(r'0 0 0 (8|9)px #241F2B',lambda m:f'0 0 0 {m.group(1)}px @@BEZEL@@',h)
    h=re.sub(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([0-9.]+)\)',_rgba,h)
    def hx(m):
        k=m.group(0); return HEX.get(k, HEX.get(k.upper(), k))
    h=re.sub(r'#[0-9A-Fa-f]{6}\b|#[fF]{3}\b',hx,h)
    # shadows: outer drop shadows of light-mode glass/cards -> none-ish handled by rgba map; orb indigo glow removed (T1)
    h=h.replace('rgba(91,95,214,0.16)','rgba(0,0,0,0)')
    h=h.replace('class="blk"','class="blk-d"').replace('class="blk ','class="blk-d ')
    h=h.replace('@@BEZEL@@','#241F2B').replace('@@WHITE@@','#FFFFFF')
    for n,k in enumerate(kbs): h=h.replace(f'@@KB{n}@@',k)
    return h
