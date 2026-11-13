import colorsys
def hx(h):
    h=h.lstrip('#'); return tuple(int(h[i:i+2],16)/255 for i in (0,2,4))
def tohex(c): return '#'+''.join(f'{max(0,min(255,round(v*255))):02X}' for v in c)
def lum(h):
    f=lambda c: c/12.92 if c<=0.03928 else ((c+0.055)/1.055)**2.4
    r,g,b=hx(h); return 0.2126*f(r)+0.7152*f(g)+0.0722*f(b)
def cr(a,b):
    x,y=sorted([lum(a),lum(b)],reverse=True); return (x+0.05)/(y+0.05)
def blend(fg,bg,a):
    f=hx(fg); b=hx(bg); return tohex(tuple(f[i]*a+b[i]*(1-a) for i in range(3)))
P={
 'P1':dict(name='Warm charcoal (recommended)',ground='#171416',surface='#1F1B1E',raised='#28232A',sheet='#2F2A30',popover='#37313A',
   text='#F3ECE4',text2='#C7BEC4',disabled='#8C838A',divider='#3E373D',accent='#5BC4B8',accentInk='#0C2523',outline='#8C838A',tonal='#1E3A37',tonalText='#A3E2D9',focus='#7FD6CB',
   error='#F2907F',warning='#E9B864',success='#82CF9F'),
 'P2':dict(name='Deeper ink (alternative)',ground='#0F0D10',surface='#171418',raised='#201C22',sheet='#272229',popover='#2F2932',
   text='#F1ECE6',text2='#C3BAC2',disabled='#857C84',divider='#37313A',accent='#57C0B4',accentInk='#0A2220',outline='#857C84',tonal='#1A3532',tonalText='#9FDFD6',focus='#7AD2C7',
   error='#F08C7C',warning='#E6B45F',success='#7ECB9B'),
}
TASK=[('Coral','coral','#E2725B','#DF6147'),('Amber','amber','#D9A23A','#AF7E22'),('Sky','sky','#4A9BD6','#338ED1'),('Indigo','indigo','#5B5FD6',None),('Teal-green','teal','#2A9D8F',None),('Rose','rose','#D9668F',None),('Green','mint','#4CA36B','#469763'),('Violet','violet','#8B5CF6',None),('Slate','slate','#6E6A75',None),('Brown','brown (new key, not approved)','#8C6A4F',None),('Plum','plum (new key, not approved)','#9E4F8F',None),('Olive','olive (new key, not approved)','#7F8A3A',None)]
def darkfill(h,surfaces,target=3.0,smax=0.70):
    if all(cr(h,s)>=target for s in surfaces): return h
    r,g,b=hx(h); H,L,S=colorsys.rgb_to_hls(r,g,b); S=min(S,smax)
    while True:
        c=tohex(colorsys.hls_to_rgb(H,L,S))
        if all(cr(c,s)>=target for s in surfaces) or L>=0.9: return c
        L+=0.005
def glyph(fill,ink):
    w=cr(fill,'#FFFFFF'); k=cr(fill,ink)
    return ('#FFFFFF',w) if w>=4.5 or w>=k else (ink,k)
FINAL={'Coral':'#E2725B','Amber':'#D9A23A','Sky':'#4A9BD6','Indigo':'#7A7EDE','Teal-green':'#2A9D8F','Rose':'#D9668F','Green':'#4CA36B','Violet':'#9672E6','Slate':'#898590','Brown':'#A67F60','Plum':'#B76FA9','Olive':'#828E3C'}
