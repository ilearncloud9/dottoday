"""ED-189: Q2 web browser-storage warning drawn on E-G4-7-States (owner authorised 2026-11-08). Adds group 'Q2' at the end; updates the Q2 labels only."""
import sys; sys.path.insert(0,'h')
from bal import elem
P='w99/project/E-G4-7-States.dc.html'
L=dict(name='Light',frame='#E9E2D6',page='#FBF7F1',side='#F3ECE2',main='#FBF7F1',ink='#241F2B',sec='#4E4757',pop='#FFFDF9',
       sh='0 0 0 1px rgba(36,31,43,.14), 0 14px 36px rgba(36,31,43,.22)',card='#F4EEE6',rule='#AF7E22',div='rgba(36,31,43,.12)',
       pb='#11615C',pf='#FFFFFF',sb='#E2EFEC',sf='#0B4642',trig='rgba(36,31,43,.07)',ring='#11615C',blk='#FFFDF9',blks='0 0 0 1px rgba(36,31,43,.10)',thread='#B9B1B8',theme='')
D=dict(name='Dark · P1',frame='#0E0C0E',page='#171416',side='#171416',main='#1F1B1E',ink='#F3ECE4',sec='#C7BEC4',pop='#37313A',
       sh='0 0 0 1px rgba(255,245,235,0.23), 0 14px 36px rgba(0,0,0,.55)',card='#2F2A30',rule='#D9A441',div='rgba(255,245,235,.14)',
       pb='#5BC4B8',pf='#171416',sb='#1E3A37',sf='#A3E2D9',trig='rgba(255,245,235,.09)',ring='#5BC4B8',blk='#28232A',blks='0 0 0 1px rgba(255,245,235,.10)',thread='#6B6369',theme=' data-theme="dark"')
CLOUD='M7 18a4.5 4.5 0 0 1-.6-8.96A6 6 0 0 1 17.8 10.6 3.75 3.75 0 0 1 17.5 18H7z'
IC={'synced':f'<path d="{CLOUD}"></path><path d="M9.5 13.5l2 2 3.5-3.5"></path>',
    'waiting':f'<path d="{CLOUD}"></path><path d="M12 16.5v-5M9.6 13.6L12 11.2l2.4 2.4"></path>',
    'device':'<rect x="7" y="3" width="10" height="18" rx="2.5"></rect><path d="M11 18h2"></path>',
    'browser':'<rect x="3" y="4" width="18" height="16" rx="2.5"></rect><path d="M3 9h18M6.5 6.5h.01M9 6.5h.01"></path>',
    'kept':'<path d="M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z"></path><path d="M9 12l2 2 4-4"></path>',
    'notkept':'<path d="M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z"></path><path d="M12 8v5M12 16v.01"></path>',
    'info':'<circle cx="12" cy="12" r="9"></circle><path d="M12 11v5M12 8v.01"></path>',
    'x':'<path d="M6 6l12 12M18 6L6 18"></path>'}
def ic(k,sz,col): return f'<svg class="i" width="{sz}" height="{sz}" viewBox="0 0 24 24" aria-hidden="true" style="color:{col}">{IC[k]}</svg>'

STATES={
 'synced':dict(trig=('synced','Synced · 10:42'),status=('synced','All changes synced','Last synced 10:42. Your tasks are on your account.'),caution=False,
               storage=('kept',"Browser storage is kept","This browser agreed to keep Dottoday's data. That makes automatic removal less likely, but clearing this site's data still removes it. Synced tasks stay on your account."),primary=False),
 'waiting':dict(trig=('device','Saved in this browser · 2 changes waiting to sync'),status=('waiting','2 changes waiting to sync','Saved in this browser. Last synced 10:42.'),caution=True,
               storage=('kept',"Browser storage is kept","Automatic removal is less likely. Clearing this site's data still removes it."),primary=True),
 'denied':dict(trig=('synced','Synced · 10:42'),status=('synced','All changes synced','Last synced 10:42. Your tasks are on your account.'),caution=False,
               storage=('notkept',"Browser storage isn't kept","This browser hasn't agreed to keep Dottoday's data, so it may remove it on its own, for example when space runs low. Synced tasks stay on your account; changes waiting to sync could be removed."),primary=False),
}
BROWSER_ROW="Dottoday also saves your tasks in this browser, so it works offline. Changes wait here until they sync."
CAUTION=("2 changes waiting to sync",["These changes are saved in this browser, but haven't synced to your account yet.","If you clear this site's data before they sync, you could lose them. Changes already synced to your account will remain there."])  # owner wording 2026-11-08 (ED-190)

def popover_body(t,st,k):
    """k = text scale (1 or 2)."""
    f=lambda px: f'{px*k:g}px'
    sk,sh_,sb_=st['status']; out=[]
    out.append(f'<div style="display:flex;align-items:center;gap:{f(8)}"><h2 id="sd-{t["name"][0]}{st["id"]}{k}" style="margin:0;flex:1;font:800 {f(15)}/{f(20)} Manrope,system-ui;color:{t["ink"]}">Sync details</h2>'
               f'<button aria-label="Close" style="width:{max(32,32*k)}px;height:{max(32,32*k)}px;border:0;border-radius:50%;background:transparent;display:flex;align-items:center;justify-content:center;flex:none">{ic("x",16*k,t["sec"])}</button></div>')
    out.append(f'<div role="status" style="display:flex;gap:{f(10)};align-items:flex-start">{ic(sk,20*k,t["ink"])}<div style="min-width:0"><div style="font:700 {f(14)}/{f(19)} Manrope,system-ui;color:{t["ink"]}">{sh_}</div><div style="font:500 {f(13)}/{f(18)} Manrope,system-ui;color:{t["sec"]}">{sb_}</div></div></div>')
    if st['caution']:
        h,b=CAUTION
        out.append(f'<div role="note" aria-label="{h}" style="border-radius:{f(12)};background:{t["card"]};box-shadow:inset {3*k}px 0 0 {t["rule"]};padding:{f(10)} {f(12)} {f(11)} {f(14)};display:flex;gap:{f(10)};align-items:flex-start">{ic("info",20*k,t["ink"])}<div style="min-width:0"><div style="font:800 {f(13.5)}/{f(18)} Manrope,system-ui;color:{t["ink"]}">{h}</div>'+''.join(f'<p style="margin:{f(3) if n else 0} 0 0;font:500 {f(13)}/{f(18)} Manrope,system-ui;color:{t["ink"]}">{p}</p>' for n,p in enumerate(b))+'</div></div>')
    out.append(f'<div style="height:1px;background:{t["div"]}"></div><div style="font:700 {f(11.5)}/{f(16)} Manrope,system-ui;color:{t["sec"]}">In this browser</div>')
    out.append(f'<div style="display:flex;gap:{f(10)};align-items:flex-start">{ic("browser",18*k,t["sec"])}<div style="font:500 {f(13)}/{f(18)} Manrope,system-ui;color:{t["ink"]};min-width:0">{BROWSER_ROW}</div></div>')
    gk,gh,gb=st['storage']
    out.append(f'<div style="display:flex;gap:{f(10)};align-items:flex-start">{ic(gk,18*k,t["sec"])}<div style="min-width:0"><div style="font:700 {f(13)}/{f(18)} Manrope,system-ui;color:{t["ink"]}">{gh}</div><div style="font:500 {f(12.5)}/{f(17)} Manrope,system-ui;color:{t["sec"]}">{gb}</div></div></div>')
    return out

def button(t,st,k):
    if st['primary']: bg,fg=t['pb'],t['pf']
    else: bg,fg=t['sb'],t['sf']
    return f'<button style="align-self:flex-start;min-height:{36*k}px;padding:0 {16*k}px;border:0;border-radius:{18*k}px;background:{bg};color:{fg};font:700 {13*k}px Manrope,system-ui">Sync now</button>'

def frame(t,sid,W=540,H=580):
    st=dict(STATES[sid],id=sid); tk,tl=st['trig']; lab=f'sd-{t["name"][0]}{sid}1'
    body=''.join(popover_body(t,st,1))+button(t,st,1)
    return (f'<div{t["theme"]} style="width:{W}px;height:{H}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{t["frame"]};overflow:hidden;flex:none">'
      f'<div style="position:relative;width:100%;height:100%;border-radius:10px;background:{t["page"]};overflow:hidden;font-family:Manrope,system-ui;color:{t["ink"]}">'
      f'<div style="position:absolute;left:216px;top:0;right:0;bottom:0;background:{t["main"]}">'
      f'<div aria-hidden="true" style="position:absolute;left:58px;top:0;bottom:0;border-left:2px dotted {t["thread"]}"></div>'
      f'<div class="num" style="position:absolute;left:12px;top:64px;font:600 11px Manrope;color:{t["sec"]}">12 PM</div>'
      f'<div style="position:absolute;left:78px;right:16px;top:52px;height:52px;border-radius:14px;background:{t["blk"]};box-shadow:{t["blks"]};padding:8px 12px;box-sizing:border-box;font:700 14px/18px Manrope;color:{t["ink"]}">Lunch<div class="num" style="font:500 12px/16px Manrope;color:{t["sec"]}">12:30–1:15</div></div>'
      f'<div class="num" style="position:absolute;left:12px;top:204px;font:600 11px Manrope;color:{t["sec"]}">2 PM</div>'
      f'<div style="position:absolute;left:78px;right:16px;top:192px;height:52px;border-radius:14px;background:{t["blk"]};box-shadow:{t["blks"]};padding:8px 12px;box-sizing:border-box;font:700 14px/18px Manrope;color:{t["ink"]}">Dentist<div class="num" style="font:500 12px/16px Manrope;color:{t["sec"]}">2:00–2:30 · From Calendar</div></div></div>'
      f'<nav aria-label="Sidebar" style="position:absolute;left:0;top:0;bottom:0;width:216px;background:{t["side"]};box-shadow:1px 0 0 {t["div"]};padding:12px;box-sizing:border-box;display:flex;flex-direction:column;font-size:14px">'
      f'<div style="font:700 12px Manrope;color:{t["sec"]};padding:6px 10px">Brain dump</div>'
      f'<div style="margin-top:auto;display:flex;flex-direction:column;gap:4px">'
      f'<button aria-haspopup="dialog" aria-expanded="true" aria-controls="{lab}" style="min-height:44px;border:0;border-radius:8px;background:{t["trig"]};box-shadow:0 0 0 2px {t["ring"]};text-align:left;display:flex;align-items:center;gap:6px;padding:4px 10px;font:600 12px/16px Manrope,system-ui;color:{t["sec"]}">{ic(tk,14,t["sec"])}<span style="min-width:0">{tl}</span></button>'
      f'<a href="#" style="height:36px;border-radius:8px;color:{t["ink"]};text-decoration:none;display:flex;align-items:center;gap:10px;padding:0 10px">Settings</a></div></nav>'
      f'<div role="dialog" aria-labelledby="{lab}" style="position:absolute;left:12px;bottom:96px;width:380px;z-index:5;border-radius:14px;background:{t["pop"]};box-shadow:{t["sh"]};padding:14px 16px 16px;box-sizing:border-box;display:flex;flex-direction:column;gap:11px">{body}</div>'
      f'</div></div>')

def frame200(t,W=640,H=760,Z=0.8):
    st=dict(STATES['waiting'],id='waiting'); lab=f'sd-{t["name"][0]}waiting2'
    body=''.join(popover_body(t,st,2))
    return (f'<div{t["theme"]} style="width:{int(W*Z)+16}px;height:{int(H*Z)+16}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{t["frame"]};overflow:hidden;flex:none"><div style="zoom:{Z}">'
      f'<div style="position:relative;width:{W}px;height:{H}px;border-radius:12px;background:{t["page"]};overflow:hidden;font-family:Manrope,system-ui;color:{t["ink"]}">'
      f'<div aria-hidden="true" style="position:absolute;inset:0;background:{t["main"]};opacity:.6"></div>'
      f'<div role="dialog" aria-labelledby="{lab}" style="position:absolute;left:8px;right:8px;top:8px;bottom:8px;border-radius:18px;background:{t["pop"]};box-shadow:{t["sh"]};display:flex;flex-direction:column;overflow:hidden">'
      f'<div style="flex:1;min-height:0;overflow:hidden;padding:20px 24px 0;display:flex;flex-direction:column;gap:18px">{body}</div>'
      f'<div aria-hidden="true" style="position:absolute;right:5px;top:90px;width:5px;height:300px;border-radius:3px;background:{t["sec"]};opacity:.55"></div>'
      f'<div style="flex:none;padding:14px 24px 18px;box-shadow:0 -1px 0 {t["div"]};background:{t["pop"]}">{button(t,st,2).replace("align-self:flex-start;","width:100%;")}</div>'
      f'</div></div></div></div>')

def section(aria,title,text,pair,w,tag='Q2 warning · for your visual approval · not merged'):
    a,b=pair
    return (f'<section aria-label="{aria}" style="display:flex;flex-direction:column;gap:8px"><div style="display:flex;gap:12px"><div style="font:700 13px Manrope;color:#6A6273;width:{w}px">Light</div><div style="font:700 13px Manrope;color:#6A6273;width:{w}px">Dark · P1</div></div>'
            f'<div style="display:flex;gap:12px;align-items:flex-start">{a}{b}</div><div style="font:500 14px/20px Manrope;color:#4E4757;width:{2*w+12}px"><div style="font:800 17px Manrope;color:#241F2B">{title}</div><div>{text}</div><span class="th" style="margin-top:6px">{tag}</span></div></section>')

NOTES=('<div style="width:2300px;border-radius:18px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.10);padding:20px 24px;font:500 15px/22px Manrope;color:#4E4757;display:flex;flex-direction:column;gap:8px">'
 '<div style="font:800 19px Manrope;color:#241F2B">Q2 warning · wording, screen readers and rules</div>'
 '<div><b>Where:</b> only in web Sync details, opened from the sidebar status line (the existing line from B6). No banner on other screens, no new destination, no Settings change. Compact and mobile web open the same content in the existing bottom-sheet pattern.</div>'
 '<div><b>When it shows:</b> the "In this browser" section is always there (calm information). The caution card appears only while changes are waiting to sync, whatever the browser answered. The storage line follows the browser\'s answer: kept, isn\'t kept, or (unsupported) "This browser can\'t be asked to keep Dottoday\'s data, so it may remove it on its own. Synced tasks stay on your account; changes waiting to sync could be removed."</div>'
 '<div><b>Truthful states:</b> "Saved in this browser" only after the local save succeeded; "Synced" and "All changes synced" only after the server confirmed. If the browser save fails, the existing "Couldn\'t save" error shows instead (A7 pattern); nothing says saved. Offline: the status reads "Offline. Changes are saved in this browser and sync when you\'re back." and Sync now is disabled.</div>'
 '<div><b>Never:</b> "clearing browser cache", "guaranteed", "always safe", red, or a re-ask button. The browser\'s own prompt (Firefox) is the only permission UI.</div>'
 '<div><b>Screen readers:</b> status line button reads "Sync details. Saved in this browser, 2 changes waiting to sync. Collapsed/Expanded." The panel is a dialog named "Sync details"; focus moves to its heading, Escape closes and returns focus to the line. The caution is a note read in full, in order: heading, then both sentences. Changes to the sync state are announced politely, once.</div>'
 '<div><b>200 % text:</b> on a 1280 px window the page is 640 px wide; the panel becomes a full-height dialog, scrolls, and keeps Sync now pinned at the bottom. Nothing is truncated.</div>'
 '<div><b>Optional, not drawn (needs your approval):</b> one line in the existing Settings data area: "Dottoday web keeps a copy in this browser. See Sync details." Not added.</div>'
 '<div><b>Open point found while drawing:</b> web can be used without signing in (A9). Then every change is only in this browser and nothing syncs; the approved request is made after sign-in only. See the decision note in the docs (Q2-W1).</div></div>')

def run():
    s=open(P).read()
    pairs=[('Q2a Web · Sync details · all changes synced','Q2a · Web · Sync details · all changes synced','Calm information: the browser keeps a copy so Dottoday works offline; synced tasks are on your account. Storage line shows the browser agreed to keep Dottoday\'s data, without promising more.','synced'),
           ('Q2b Web · Sync details · changes waiting to sync','Q2b · Web · Sync details · changes waiting to sync','The caution card appears only now: these changes are only in this browser until they sync. Sync now is the primary action. Status says "Saved in this browser" because the local save succeeded; it never says synced.','waiting'),
           ('Q2c Web · Sync details · browser storage not kept','Q2c · Web · Sync details · storage not kept (denied)','The browser said no (or can\'t be asked). Dottoday works normally; the line explains the risk once, with no re-ask and no nag. Unsupported uses the same line with "can\'t be asked".','denied')]
    secs=''.join(section(a,ti,tx,(frame(L,sid),frame(D,sid)),540) for a,ti,tx,sid in pairs)
    s200=section('Q2d Web · 200 % text · changes waiting to sync','Q2d · Web · 200 % text · changes waiting to sync','Browser zoom 200 % (640 px page): one column, wraps fully, panel scrolls, Sync now stays reachable. Drawn at 80 %.',(frame200(L),frame200(D)),528)
    grp=('<div style="display:flex;flex-direction:column;gap:16px"><div><div style="font-size:26px;font-weight:800">Q2 · Web · what this browser keeps (ED-188 approved; warning drawn for approval, ED-189)</div>'
         '<div style="font-size:16px;color:#4E4757;max-width:3400px">Inside the existing web Sync details only. Local saving and server sync are separate lines; the browser\'s storage answer is a third, separate line.</div></div>'
         f'<div style="display:flex;gap:40px;row-gap:36px;align-items:flex-start;flex-wrap:wrap">{secs}</div>'
         f'<div style="display:flex;gap:40px;align-items:flex-start">{s200}{NOTES}</div></div>')
    r=s.index('<div style="width: 3600px; height: 6440px'); e=elem(s,r)
    s=s[:e-6]+grp+s[e-6:]
    s=s.replace('<div style="width: 3600px; height: 6440px','<div style="width: 3600px; height: 8000px',1)
    s=s.replace('"height&quot;:6440','"height&quot;:8000').replace('&quot;height&quot;:6440','&quot;height&quot;:8000')
    old=('<div><b>Q2 · Web storage</b>: the browser can clear web data unless the app asks it to keep it. Recommended: ask the browser to keep storage on sign-in, and until then say "Saved in this browser". Implementation dependency, not a design change.</div>')
    assert s.count(old)==1
    s=s.replace(old,'<div><b>Q2 · Web storage · option A approved 2026-11-08 (ED-188)</b>: after sign-in the web app asks the browser to keep its storage; web keeps "Saved in this browser". The warning in web Sync details is drawn below (Q2a to Q2d, ED-189) for your visual approval. Implementation not done (CR-159).</div>')
    old2='Web says "Saved in this browser" (not "on this device"); see decision Q2 about asking the browser to keep storage.'
    assert s.count(old2)==1
    s=s.replace(old2,'Web says "Saved in this browser" (not "on this device"). Q2 option A approved (ED-188); the browser-storage warning is in Sync details, Q2a to Q2d below.')
    s=s.replace('Decisions: Q1 approved; Q2 to Q5 open (nothing below is merged)','Decisions: Q1 and Q2 option A approved; Q2 warning awaiting approval; Q3 to Q5 open (nothing below is merged)')
    open(P,'w').write(s); print('ok')
if __name__=='__main__': run()
