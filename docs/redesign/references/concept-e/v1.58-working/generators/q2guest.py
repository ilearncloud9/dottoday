"""ED-192: Q2-W1 option A (owner, 2026-11-08): guest web status and browser-only warning on E-G4-7-States.
Builds on w100 (ED-191). Adds section Q2e (1:1) and Q2f (200 %, drawn at 50 %) beside Q2d; condenses the Q2 notes box to fit the 8000 px board."""
import sys, json; sys.path.insert(0,'h')
from bal import elem
import q2warn as W
SRC='w100/project/E-G4-7-States.dc.html'; OUT='w101/project/E-G4-7-States.dc.html'
SUPPORT=json.load(open('h/guest_support.json'))   # {"line": str|None}
GUEST_STATUS=('device','Not signed in','Saved in this browser.')
CARD_H='Only saved in this browser'
CARD_B=["Your tasks are only stored in this browser. If you clear this site's data, you could lose them."]+([SUPPORT['line']] if SUPPORT['line'] else [])

def body(t,k):
    f=lambda px: f'{px*k:g}px'; ic=W.ic; out=[]
    out.append(f'<div style="display:flex;align-items:center;gap:{f(8)}"><h2 style="margin:0;flex:1;font:800 {f(15)}/{f(20)} Manrope,system-ui;color:{t["ink"]}">Sync details</h2>'
               f'<button aria-label="Close" style="width:{max(32,32*k)}px;height:{max(32,32*k)}px;border:0;border-radius:50%;background:transparent;display:flex;align-items:center;justify-content:center;flex:none">{ic("x",16*k,t["sec"])}</button></div>')
    sk,sh_,sb_=GUEST_STATUS
    out.append(f'<div role="status" style="display:flex;gap:{f(10)};align-items:flex-start">{ic(sk,20*k,t["ink"])}<div style="min-width:0"><div style="font:700 {f(14)}/{f(19)} Manrope,system-ui;color:{t["ink"]}">{sh_}</div><div style="font:500 {f(13)}/{f(18)} Manrope,system-ui;color:{t["sec"]}">{sb_}</div></div></div>')
    out.append(f'<div role="note" aria-label="{CARD_H}" style="border-radius:{f(12)};background:{t["card"]};box-shadow:inset {3*k}px 0 0 {t["rule"]};padding:{f(10)} {f(12)} {f(11)} {f(14)};display:flex;gap:{f(10)};align-items:flex-start">{ic("info",20*k,t["ink"])}<div style="min-width:0"><div style="font:800 {f(13.5)}/{f(18)} Manrope,system-ui;color:{t["ink"]}">{CARD_H}</div>'
               +''.join(f'<p style="margin:{f(3) if n else 0} 0 0;font:500 {f(13)}/{f(18)} Manrope,system-ui;color:{t["ink"]}">{p}</p>' for n,p in enumerate(CARD_B))+'</div></div>')
    out.append(f'<div style="height:1px;background:{t["div"]}"></div><div style="font:700 {f(11.5)}/{f(16)} Manrope,system-ui;color:{t["sec"]}">In this browser</div>')
    out.append(f'<div style="display:flex;gap:{f(10)};align-items:flex-start">{ic("kept",18*k,t["sec"])}<div style="min-width:0"><div style="font:700 {f(13)}/{f(18)} Manrope,system-ui;color:{t["ink"]}">Browser storage is kept</div><div style="font:500 {f(12.5)}/{f(17)} Manrope,system-ui;color:{t["sec"]}">Asked after your first saved change. Automatic removal is less likely. Clearing this site\'s data still removes it.</div></div></div>')
    return ''.join(out)

def signin(t,k,full=False):
    w='width:100%;' if full else 'align-self:flex-start;'
    return f'<button style="{w}min-height:{36*k}px;padding:0 {16*k}px;border:0;border-radius:{18*k}px;background:{t["pb"]};color:{t["pf"]};font:700 {13*k}px Manrope,system-ui">Sign in</button>'

def frame(t,W_=460,H=560):
    lab=f'sdg-{t["name"][0]}'
    return (f'<div{t["theme"]} style="width:{W_}px;height:{H}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{t["frame"]};overflow:hidden;flex:none">'
      f'<div style="position:relative;width:100%;height:100%;border-radius:10px;background:{t["page"]};overflow:hidden;font-family:Manrope,system-ui;color:{t["ink"]}">'
      f'<div style="position:absolute;left:216px;top:0;right:0;bottom:0;background:{t["main"]}"><div aria-hidden="true" style="position:absolute;left:58px;top:0;bottom:0;border-left:2px dotted {t["thread"]}"></div></div>'
      f'<nav aria-label="Sidebar" style="position:absolute;left:0;top:0;bottom:0;width:216px;background:{t["side"]};box-shadow:1px 0 0 {t["div"]};padding:12px;box-sizing:border-box;display:flex;flex-direction:column;font-size:14px">'
      f'<div style="font:700 12px Manrope;color:{t["sec"]};padding:6px 10px">Brain dump</div><div style="margin-top:auto;display:flex;flex-direction:column;gap:4px">'
      f'<button aria-haspopup="dialog" aria-expanded="true" aria-controls="{lab}" style="min-height:44px;border:0;border-radius:8px;background:{t["trig"]};box-shadow:0 0 0 2px {t["ring"]};text-align:left;display:flex;align-items:center;gap:6px;padding:4px 10px;font:600 12px/16px Manrope,system-ui;color:{t["sec"]}">{W.ic("device",14,t["sec"])}<span style="min-width:0">Not signed in · saved in this browser</span></button>'
      f'<a href="#" style="height:36px;border-radius:8px;color:{t["ink"]};text-decoration:none;display:flex;align-items:center;gap:10px;padding:0 10px">Settings</a></div></nav>'
      f'<div role="dialog" id="{lab}" aria-label="Sync details" style="position:absolute;left:12px;bottom:96px;width:380px;z-index:5;border-radius:14px;background:{t["pop"]};box-shadow:{t["sh"]};padding:14px 16px 16px;box-sizing:border-box;display:flex;flex-direction:column;gap:11px">{body(t,1)}{signin(t,1)}</div>'
      f'</div></div>')

def frame200(t,Wd=640,H=760,Z=0.5):
    return (f'<div{t["theme"]} style="width:{int(Wd*Z)+16}px;height:{int(H*Z)+16}px;padding:8px;box-sizing:border-box;border-radius:14px;background:{t["frame"]};overflow:hidden;flex:none"><div style="zoom:{Z}">'
      f'<div style="position:relative;width:{Wd}px;height:{H}px;border-radius:12px;background:{t["page"]};overflow:hidden;font-family:Manrope,system-ui;color:{t["ink"]}">'
      f'<div aria-hidden="true" style="position:absolute;inset:0;background:{t["main"]};opacity:.6"></div>'
      f'<div role="dialog" aria-label="Sync details" style="position:absolute;left:8px;right:8px;top:8px;bottom:8px;border-radius:18px;background:{t["pop"]};box-shadow:{t["sh"]};display:flex;flex-direction:column;overflow:hidden">'
      f'<div style="flex:1;min-height:0;overflow:hidden;padding:20px 24px 0;display:flex;flex-direction:column;gap:18px">{body(t,2)}</div>'
      f'<div aria-hidden="true" style="position:absolute;right:5px;top:90px;width:5px;height:300px;border-radius:3px;background:{t["sec"]};opacity:.55"></div>'
      f'<div style="flex:none;padding:14px 24px 18px;box-shadow:0 -1px 0 {t["div"]};background:{t["pop"]}">{signin(t,2,True)}</div></div></div></div></div>')

TAG='Q2-W1 guest · approved direction (ED-192) · not merged'
NOTES=('<div style="width:{w}px;box-sizing:border-box;border-radius:18px;background:#FFFDF9;box-shadow:0 0 0 1px rgba(36,31,43,.10);padding:18px 22px;font:500 14px/20px Manrope;color:#4E4757;display:flex;flex-direction:column;gap:6px">'
 '<div style="font:800 18px Manrope;color:#241F2B">Q2 · wording, screen readers and rules</div>'
 '<div><b>Where:</b> web Sync details only, opened from the sidebar status line. No banner elsewhere, no new destination, no Settings change; compact web uses the existing bottom sheet.</div>'
 '<div><b>Signed in:</b> "In this browser" always; the caution card only while changes wait to sync; storage line kept / isn\'t kept / can\'t be asked (unsupported).</div>'
 '<div><b>Not signed in:</b> status "Not signed in · saved in this browser" only after a successful browser save; card "Only saved in this browser"; Sign in opens the existing sign-in. Storage is asked after the first saved change.</div>'
 '<div><b>Truthful:</b> "Synced" only after the server confirms; a failed save shows "Couldn\'t save" (A7); offline disables Sync now. Never "Saved on this device" or "Saved to your account" on web before it is true.</div>'
 '<div><b>Never:</b> "clearing browser cache", "guaranteed", red, a re-ask button.</div>'
 '<div><b>Screen readers:</b> the status line is a button "Sync details, [status], collapsed or expanded"; the panel is a dialog "Sync details"; focus moves to its heading; Escape returns to the line; a note is read heading first, then its sentences; state changes are announced politely, once.</div>'
 '<div><b>200 % text:</b> full-height dialog, scrolls, main action pinned. Not drawn: the optional Settings line (not approved).</div></div>')

def run():
    s=open(SRC).read()
    # condense the existing notes box (annotation only)
    a=s.index('<div style="font:800 19px Manrope;color:#241F2B">Q2 warning · wording, screen readers and rules</div>')
    a=s.rfind('<div style="width:2300px;',0,a); e=elem(s,a)
    guest=W.section('Q2e Web · not signed in · saved in this browser','Q2e · Web · not signed in · saved in this browser',
        'Shown only after the browser save succeeded. Nothing syncs, so the card says the tasks are only here. Sign in is the main action (existing sign-in). No promise that tasks move to the account until that move is verified (ED-192).',(frame(W.L),frame(W.D)),460,TAG)
    g200=W.section('Q2f Web · not signed in · 200 % text','Q2f · Web · not signed in · 200 % text','640 px page: wraps, scrolls, Sign in pinned. Drawn at 50 %.',(frame200(W.L),frame200(W.D)),336,TAG)
    s=s[:a]+guest+g200+NOTES.format(w=716)+s[e:]
    s=s.replace('Q2 · Web · what this browser keeps (ED-188 and the warning approved, ED-191)','Q2 · Web · what this browser keeps (ED-188, ED-191; not-signed-in web ED-192) · Q2 closed at design level')
    old='The warning in web Sync details (Q2a to Q2d) is approved (ED-191). Q2-W1 (web without sign-in) open.'
    assert s.count(old)==1
    s=s.replace(old,'The warning in web Sync details (Q2a to Q2d) is approved (ED-191). Not signed in: Q2-W1 option A approved, Q2e and Q2f (ED-192). <b>Q2 closed at design level</b>; implementation open (CR-159).')
    s=s.replace('Decisions: Q1 and Q2 approved; Q2-W1 and Q3 to Q5 open','Decisions: Q1 and Q2 closed at design level; Q3 to Q5 open')
    open(OUT,'w').write(s); print('ok')
if __name__=='__main__': run()
